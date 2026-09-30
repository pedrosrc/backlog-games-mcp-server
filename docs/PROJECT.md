# Backlog Games MCP Server — Project Guide

## What it is

A backlog manager for video games, exposed through the Model Context Protocol.
An MCP client (for example an AI assistant) can:

- search for games by name,
- add games to a user's backlog with a status (`pending`, `playing`, `completed`),
- list a user's backlog,
- rate games from 0 to 10,
- get recommendations based on the average rating of games the user has not
  added to their backlog yet.

The app is Rails 8.1 with `config.api_only = true`. There are no controllers or
views; `config/routes.rb` only defines the `/up` health check. All client-facing
behavior lives in MCP tools.

## How it works

### Layers

```
MCP client
   │  tool call (name + JSON arguments)
   ▼
app/mcp/tools/*      MCP::Tool subclasses: name, description, input schema
   │  ::Service.call(arguments with string keys)
   ▼
app/services/*       plain Ruby objects with the business logic
   │
   ▼
app/models/*         ActiveRecord models (PostgreSQL)
```

- **Tools** (`app/mcp/tools/`, namespace `Tools`) are thin. Each declares
  `tool_name`, `description` and `input_schema`, and its `self.call(**arguments)`
  forwards the arguments to the same-named service with `stringify_keys`. The
  `mcp` gem passes keyword arguments with symbol keys; services read string keys.
  Services are referenced as `::SearchGame` etc. because inside `Tools` the bare
  name would resolve to the tool class itself.
- **Services** (`app/services/`) expose a single `self.call(arguments)`. They
  validate input, look records up with `Model.find`, and rescue
  `ActiveRecord::RecordNotFound` into an error response.

### Response shape

Success:

```ruby
{ content: [ { type: "text", text: "..." } ] }
```

Error (validation failure or record not found):

```ruby
{ content: [ { type: "text", text: "`user_id` is required" } ], is_error: true }
```

### Domain model

| Model         | Columns (besides timestamps)                | Notes                                       |
| ------------- | ------------------------------------------- | ------------------------------------------- |
| `User`        | `name`                                      | has many backlog items                      |
| `Game`        | `name`                                      | has many backlog items and ratings          |
| `BacklogItem` | `user_id`, `game_id`, `status`              | `status` defaults to `pending`              |
| `Rating`      | `user_id`, `game_id`, `rating` (float)      | unique per `(user_id, game_id)`             |

### Tool behavior

- **`search_game`** — case-insensitive partial match on `games.name` (`ILIKE`),
  `%` and `_` in the query are treated literally. Ordered by name, max 10 results.
  Each result includes the game ID so it can be used with the other tools.
- **`add_to_backlog`** — requires `user_id` and `game_id`; `status` must be one of
  `pending`, `playing`, `completed` (default `pending`).
- **`list_backlog`** — one text entry per item (`Game `X` - Status: Y`), or a
  message saying the backlog is empty.
- **`rate_game`** — `rating` must be a number in `0..10`. Uses
  `find_or_initialize_by`, so rating the same game again updates the rating.
- **`recommend_game`** — up to 5 games not in the user's backlog, ordered by
  average rating (unrated games count as 0).

## Development setup

1. Install Ruby (see `.ruby-version`), PostgreSQL and run `bundle install`.
2. Create `.env` with `DEV_POSTGRES_HOST`, `DEV_POSTGRES_USER` and
   `DEV_POSTGRES_PASSWORD`. `config/database.yml` uses them for both
   `development` and `test`.
3. `bin/rails db:setup`

## Testing

The suite uses Minitest (no fixtures; tests create their own records).

```bash
bin/rails db:test:prepare test
```

`db:test:prepare` loads `db/schema.rb` into the test database, so run it after
any migration.

| Path                          | Covers                                                                 |
| ----------------------------- | ---------------------------------------------------------------------- |
| `test/services/*_test.rb`     | One file per service: happy path, required args, invalid values, missing records |
| `test/mcp/tools/tools_test.rb`| Tool name, description and `required` schema; that each tool forwards symbol-keyed arguments to its service |
| `test/test_helper.rb`         | Shared helpers: `texts`, `assert_success`, `assert_error`, `create_user`, `create_game` |

The tests exercise tools and services directly. They do not start the MCP
server or perform a real client handshake.

Other checks run in CI: `bin/rubocop`, `bin/brakeman --no-pager` and
`bin/bundler-audit`.

## Adding a new tool

1. Create `app/services/my_tool.rb` with `self.call(arguments)`, a private
   `validate` and a private `error` helper, following the existing services.
2. Create `app/mcp/tools/my_tool.rb`:

   ```ruby
   module Tools
     class MyTool < MCP::Tool
       tool_name "my_tool"
       description "What it does"
       input_schema(
         properties: { user_id: { type: "integer", description: "ID of User" } },
         required: [ "user_id" ]
       )

       def self.call(**arguments)
         ::MyTool.call(arguments.stringify_keys)
       end
     end
   end
   ```
3. Add `test/services/my_tool_test.rb` and an entry in `test/mcp/tools/tools_test.rb`.
4. Run `bin/rails db:test:prepare test` and `bin/rubocop`.

If the feature needs new columns, check `db/schema.rb` and add a migration first.

## Known gaps

- **Server bootstrap:** `config.ru` calls `Rails.application.load_server`, but no
  such method is defined in the repo, and no `MCP::Server` is created or given
  the tools. Until this is wired, the app cannot be started as an MCP server.
- **Response type:** tools return plain hashes. The `mcp` gem's server may expect
  `MCP::Tool::Response`; verify once the server is wired.
- **No data-entry tools:** there are no tools to create users or games, so they
  must be created through the Rails console or seeds.

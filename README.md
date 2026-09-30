# Backlog Games MCP Server

A Rails 8.1 API-only application that exposes a game backlog manager as an
[MCP](https://modelcontextprotocol.io) (Model Context Protocol) server. Instead
of a REST API, an MCP client (such as Claude) calls tools to search games, manage
a backlog, rate games and get recommendations.

> **Status:** the tools, services, models and tests are in place. The MCP server
> bootstrap is not wired yet: `config.ru` calls `Rails.application.load_server`,
> which is not defined anywhere in the repo. See
> [Known gaps](docs/PROJECT.md#known-gaps).

## Tools

| Tool             | Arguments                                        | Description                                  |
| ---------------- | ------------------------------------------------ | -------------------------------------------- |
| `search_game`    | `query`                                          | Finds games by (partial) name                |
| `add_to_backlog` | `user_id`, `game_id`, `status` (optional)        | Adds a game to a user's backlog              |
| `list_backlog`   | `user_id`                                        | Lists a user's backlog with statuses         |
| `rate_game`      | `user_id`, `game_id`, `rating` (0–10)            | Creates or updates a user's rating of a game |
| `recommend_game` | `user_id`                                        | Suggests top-rated games not yet in backlog  |

## Requirements

- Ruby (version in `.ruby-version`)
- PostgreSQL
- Bundler

## Setup

```bash
bundle install
```

Create a `.env` file (loaded by `dotenv`) with the database connection:

```
DEV_POSTGRES_HOST=localhost
DEV_POSTGRES_USER=postgres
DEV_POSTGRES_PASSWORD=secret
```

Then create the database:

```bash
bin/rails db:setup
```

## Running the tests

```bash
bin/rails db:test:prepare test
```

Run a subset:

```bash
bin/rails test test/services                        # services only
bin/rails test test/mcp                             # tools only
bin/rails test test/services/rate_game_test.rb:12   # a single test by line
```

## Quality checks

```bash
bin/rubocop                    # lint (Omakase style)
bin/brakeman --no-pager        # static security analysis
bin/bundler-audit              # vulnerable dependencies
```

CI (`.github/workflows/ci.yml`) runs all of the above on every PR and push to `main`.

## Documentation

See [docs/PROJECT.md](docs/PROJECT.md) for how the project is structured, how a
tool call flows through the code, and how to add a new tool.

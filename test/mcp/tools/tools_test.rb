require "test_helper"

class ToolsTest < ActiveSupport::TestCase
  TOOLS = {
    Tools::CreateUser => { name: "create_user", required: %w[name email] },
    Tools::CreateGame => { name: "create_game", required: %w[name] },
    Tools::AddToBacklog => { name: "add_to_backlog", required: %w[game_id user_id] },
    Tools::RemoveFromBacklog => { name: "remove_from_backlog", required: %w[user_id game_id] },
    Tools::ListBacklog => { name: "list_backlog", required: %w[user_id] },
    Tools::RateGame => { name: "rate_game", required: %w[user_id game_id rating] },
    Tools::RecommendGame => { name: "recommend_game", required: %w[user_id] },
    Tools::SearchGame => { name: "search_game", required: %w[query] }
  }.freeze

  TOOLS.each do |tool, expected|
    test "#{tool.name} declares its name, description and schema" do
      assert_equal expected[:name], tool.name_value
      assert tool.description_value.present?

      schema = tool.input_schema.to_h
      assert_equal expected[:required].sort, schema[:required].map(&:to_s).sort
      assert_equal expected[:required].sort, (schema[:required].map(&:to_s) & schema[:properties].keys.map(&:to_s)).sort
    end
  end

  test "add_to_backlog forwards symbol keyword arguments to the service" do
    user = create_user
    game = create_game

    response = Tools::AddToBacklog.call(user_id: user.id, game_id: game.id, status: "playing")

    assert_success response
    assert_equal "playing", BacklogItem.last.status
  end

  test "list_backlog forwards to the service" do
    user = create_user
    BacklogItem.create!(user: user, game: create_game, status: "pending")

    assert_equal [ "Game `Zelda` - Status: pending" ], texts(Tools::ListBacklog.call(user_id: user.id))
  end

  test "remove_from_backlog forwards to the service" do
    user = create_user
    game = create_game
    BacklogItem.create!(user: user, game: game)

    assert_equal [ "Game `Zelda` removed from backlog" ], texts(Tools::RemoveFromBacklog.call(user_id: user.id, game_id: game.id))
    assert_equal 0, BacklogItem.count
  end

  test "rate_game forwards to the service" do
    user = create_user
    game = create_game

    assert_success Tools::RateGame.call(user_id: user.id, game_id: game.id, rating: 8)
    assert_equal 8.0, Rating.last.rating
  end

  test "recommend_game forwards to the service" do
    user = create_user
    create_game(name: "Halo")

    assert_equal [ "Here are some games you might like, Ana: Halo" ], texts(Tools::RecommendGame.call(user_id: user.id))
  end

  test "search_game forwards to the service" do
    game = create_game(name: "Halo")

    assert_equal [ "Game `Halo` - ID: #{game.id}" ], texts(Tools::SearchGame.call(query: "hal"))
  end

  test "create_user and create_game forward to the services and return structured content" do
    user_response = Tools::CreateUser.call(name: "Ana", email: "ana@example.com")
    game_response = Tools::CreateGame.call(name: "Halo")

    assert_equal({ id: User.last.id, name: "Ana", email: "ana@example.com" }, user_response.structured_content)
    assert_equal({ id: Game.last.id, name: "Halo" }, game_response.structured_content)
  end

  test "search_game returns structured content" do
    game = create_game(name: "Halo")

    assert_equal({ games: [ { id: game.id, name: "Halo" } ] }, Tools::SearchGame.call(query: "hal").structured_content)
  end

  test "tools return MCP::Tool::Response objects" do
    assert_kind_of MCP::Tool::Response, Tools::SearchGame.call(query: "x")
    assert Tools::SearchGame.call(query: "").error?
  end

  test "tools surface service errors" do
    assert_error Tools::SearchGame.call(query: ""), "`query` is required"
  end
end

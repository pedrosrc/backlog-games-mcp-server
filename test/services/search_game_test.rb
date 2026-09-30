require "test_helper"

class SearchGameTest < ActiveSupport::TestCase
  test "finds games case-insensitively by partial name" do
    zelda = create_game(name: "The Legend of Zelda")
    create_game(name: "Mario")

    response = SearchGame.call("query" => "zeLDa")

    assert_success response
    assert_equal [ "Game `The Legend of Zelda` - ID: #{zelda.id}" ], texts(response)
  end

  test "orders results by name" do
    create_game(name: "Halo 2")
    create_game(name: "Halo 1")

    assert_equal [ "Halo 1", "Halo 2" ], texts(SearchGame.call("query" => "halo")).map { |t| t[/`(.+)`/, 1] }
  end

  test "treats LIKE wildcards literally" do
    create_game(name: "Mario")

    assert_equal [ "No games found for `%`" ], texts(SearchGame.call("query" => "%"))
  end

  test "limits results" do
    (SearchGame::SEARCH_LIMIT + 3).times { |i| create_game(name: "Game #{i}") }

    assert_equal SearchGame::SEARCH_LIMIT, SearchGame.call("query" => "game")[:content].size
  end

  test "reports when nothing matches" do
    response = SearchGame.call("query" => "nope")

    assert_success response
    assert_equal [ "No games found for `nope`" ], texts(response)
  end

  test "requires query" do
    assert_error SearchGame.call({}), "`query` is required"
    assert_error SearchGame.call("query" => "  "), "`query` is required"
  end
end

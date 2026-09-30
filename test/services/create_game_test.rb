require "test_helper"

class CreateGameTest < ActiveSupport::TestCase
  test "creates a game and returns its ID" do
    response = CreateGame.call("name" => "  Zelda ")

    user = Game.find_by!(name: "Zelda")
    assert_success response
    assert_equal [ "Game `Zelda` created - ID: #{user.id}" ], texts(response)
    assert_equal({ id: user.id, name: "Zelda" }, response[:structured_content])
  end

  test "requires name" do
    assert_error CreateGame.call({}), "`name` is required"
    assert_error CreateGame.call("name" => "  "), "`name` is required"
    assert_equal 0, Game.count
  end
end

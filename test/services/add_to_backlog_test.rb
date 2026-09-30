require "test_helper"

class AddToBacklogTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @game = create_game
  end

  test "adds game with default pending status" do
    response = AddToBacklog.call("user_id" => @user.id, "game_id" => @game.id)

    assert_success response
    assert_equal [ "Game `Zelda` added to backlog" ], texts(response)
    assert_equal "pending", BacklogItem.find_by!(user: @user, game: @game).status
  end

  test "uses the given status" do
    AddToBacklog.call("user_id" => @user.id, "game_id" => @game.id, "status" => "playing")

    assert_equal "playing", BacklogItem.last.status
  end

  test "requires user_id and game_id" do
    assert_error AddToBacklog.call("game_id" => @game.id), "`user_id` and `game_id` are required"
    assert_error AddToBacklog.call("user_id" => @user.id), "`user_id` and `game_id` are required"
  end

  test "rejects invalid status" do
    response = AddToBacklog.call("user_id" => @user.id, "game_id" => @game.id, "status" => "dropped")

    assert_error response, "`status` must be one of: pending, playing, completed"
    assert_equal 0, BacklogItem.count
  end

  test "returns error when user or game is missing" do
    assert_error AddToBacklog.call("user_id" => 0, "game_id" => @game.id), "User or Game not found"
    assert_error AddToBacklog.call("user_id" => @user.id, "game_id" => 0), "User or Game not found"
  end
end

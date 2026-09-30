require "test_helper"

class RemoveFromBacklogTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @game = create_game
  end

  test "removes the game from the user's backlog" do
    BacklogItem.create!(user: @user, game: @game)

    response = RemoveFromBacklog.call("user_id" => @user.id, "game_id" => @game.id)

    assert_success response
    assert_equal [ "Game `Zelda` removed from backlog" ], texts(response)
    assert_equal 0, BacklogItem.count
  end

  test "keeps the rating and other users' items" do
    other = create_user(name: "Bia")
    BacklogItem.create!(user: @user, game: @game)
    BacklogItem.create!(user: other, game: @game)
    Rating.create!(user: @user, game: @game, rating: 8)

    RemoveFromBacklog.call("user_id" => @user.id, "game_id" => @game.id)

    assert_equal [ other.id ], BacklogItem.pluck(:user_id)
    assert_equal 1, Rating.count
  end

  test "errors when the game is not in the backlog" do
    assert_error RemoveFromBacklog.call("user_id" => @user.id, "game_id" => @game.id),
                 "Game `Zelda` is not in the backlog"
  end

  test "requires user_id and game_id" do
    assert_error RemoveFromBacklog.call("game_id" => @game.id), "`user_id` and `game_id` are required"
    assert_error RemoveFromBacklog.call("user_id" => @user.id), "`user_id` and `game_id` are required"
  end

  test "returns error when user or game is missing" do
    assert_error RemoveFromBacklog.call("user_id" => 0, "game_id" => @game.id), "User or Game not found"
    assert_error RemoveFromBacklog.call("user_id" => @user.id, "game_id" => 0), "User or Game not found"
  end
end

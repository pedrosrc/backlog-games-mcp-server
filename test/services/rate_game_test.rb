require "test_helper"

class RateGameTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @game = create_game
  end

  test "creates a rating" do
    response = RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 8.5)

    assert_success response
    assert_equal [ "Game `Zelda` rated 8.5 by user `Ana`" ], texts(response)
    assert_equal 8.5, Rating.find_by!(user: @user, game: @game).rating
  end

  test "accepts numeric strings" do
    RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => "7")

    assert_equal 7.0, Rating.last.rating
  end

  test "updates the existing rating instead of duplicating" do
    RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 5)
    RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 9)

    assert_equal 1, Rating.count
    assert_equal 9.0, Rating.last.rating
  end

  test "accepts the range boundaries" do
    assert_success RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 0)
    assert_success RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 10)
  end

  test "requires all arguments" do
    message = "`user_id`, `game_id` and `rating` are required"

    assert_error RateGame.call("game_id" => @game.id, "rating" => 5), message
    assert_error RateGame.call("user_id" => @user.id, "rating" => 5), message
    assert_error RateGame.call("user_id" => @user.id, "game_id" => @game.id), message
  end

  test "rejects non numeric rating" do
    response = RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => "abc")

    assert_error response, "`rating` must be a number between 0 and 10"
  end

  test "rejects out of range rating" do
    assert_error RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => 11),
                 "`rating` must be between 0 and 10"
    assert_error RateGame.call("user_id" => @user.id, "game_id" => @game.id, "rating" => -1),
                 "`rating` must be between 0 and 10"
    assert_equal 0, Rating.count
  end

  test "returns error when user or game is missing" do
    assert_error RateGame.call("user_id" => 0, "game_id" => @game.id, "rating" => 5), "User or Game not found"
    assert_error RateGame.call("user_id" => @user.id, "game_id" => 0, "rating" => 5), "User or Game not found"
  end
end

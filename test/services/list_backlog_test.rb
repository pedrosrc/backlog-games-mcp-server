require "test_helper"

class ListBacklogTest < ActiveSupport::TestCase
  setup { @user = create_user }

  test "lists games with status" do
    BacklogItem.create!(user: @user, game: create_game(name: "Zelda"), status: "playing")
    BacklogItem.create!(user: @user, game: create_game(name: "Mario"), status: "completed")

    response = ListBacklog.call("user_id" => @user.id)

    assert_success response
    assert_equal [ "Game `Zelda` - Status: playing", "Game `Mario` - Status: completed" ], texts(response)
  end

  test "returns structured items with game ID, status and the user's rating" do
    zelda = create_game(name: "Zelda")
    mario = create_game(name: "Mario")
    BacklogItem.create!(user: @user, game: zelda, status: "playing")
    BacklogItem.create!(user: @user, game: mario, status: "pending")
    Rating.create!(user: @user, game: zelda, rating: 9.5)
    Rating.create!(user: create_user(name: "Bia"), game: mario, rating: 2)

    items = ListBacklog.call("user_id" => @user.id)[:structured_content][:items]

    assert_equal [
      { game_id: zelda.id, name: "Zelda", status: "playing", rating: 9.5 },
      { game_id: mario.id, name: "Mario", status: "pending", rating: nil }
    ], items
  end

  test "structured items are empty for an empty backlog" do
    assert_equal({ items: [] }, ListBacklog.call("user_id" => @user.id)[:structured_content])
  end

  test "does not list other users' items" do
    BacklogItem.create!(user: create_user(name: "Bia"), game: create_game)

    assert_equal [ "Backlog is empty for user `Ana`" ], texts(ListBacklog.call("user_id" => @user.id))
  end

  test "reports empty backlog" do
    response = ListBacklog.call("user_id" => @user.id)

    assert_success response
    assert_equal [ "Backlog is empty for user `Ana`" ], texts(response)
  end

  test "requires user_id" do
    assert_error ListBacklog.call({}), "`user_id` is required"
  end

  test "returns error when user is missing" do
    assert_error ListBacklog.call("user_id" => 0), "User not found"
  end
end

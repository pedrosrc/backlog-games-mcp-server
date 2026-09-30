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

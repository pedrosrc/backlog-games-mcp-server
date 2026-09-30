require "test_helper"

class RecommendGameTest < ActiveSupport::TestCase
  setup { @user = create_user }

  test "recommends games ordered by average rating" do
    low = create_game(name: "Low")
    high = create_game(name: "High")
    other = create_user(name: "Bia")
    Rating.create!(user: other, game: low, rating: 3)
    Rating.create!(user: other, game: high, rating: 9)

    response = RecommendGame.call("user_id" => @user.id)

    assert_success response
    assert_equal [ "Here are some games you might like, Ana: High, Low" ], texts(response)
  end

  test "excludes games already in the backlog" do
    owned = create_game(name: "Owned")
    create_game(name: "New")
    BacklogItem.create!(user: @user, game: owned)

    text = texts(RecommendGame.call("user_id" => @user.id)).first

    assert_includes text, "New"
    assert_not_includes text, "Owned"
  end

  test "limits the number of recommendations" do
    (RecommendGame::RECOMMENDATION_LIMIT + 2).times { |i| create_game(name: "Game #{i}") }

    text = texts(RecommendGame.call("user_id" => @user.id)).first
    list = text.split(": ", 2).last

    assert_equal RecommendGame::RECOMMENDATION_LIMIT, list.split(", ").size
  end

  test "reports when there is nothing to recommend" do
    response = RecommendGame.call("user_id" => @user.id)

    assert_success response
    assert_equal [ "No new games to recommend right now, Ana!" ], texts(response)
  end

  test "requires user_id" do
    assert_error RecommendGame.call({}), "`user_id` is required"
  end

  test "returns error when user is missing" do
    assert_error RecommendGame.call("user_id" => 0), "User not found"
  end
end

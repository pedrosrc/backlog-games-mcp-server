class RateGame
  def self.call(arguments)
    user = User.find(arguments["user_id"])
    game = Game.find(arguments["game_id"])
    return if user.blank? || game.blank? || arguments["rating"].blank?

    rating = arguments["rating"].to_f
    return if rating < 0 || rating > 10

    game_rating = Rating.find_or_initialize_by(user: user, game: game)
    game_rating.rating = rating
    game_rating.save!

    {
      content: [
        {
          type: "text",
          text: "Game `#{game.name}` rated #{rating} by user `#{user.name}`"
        }
      ]
    }
  rescue ActiveRecord::RecordNotFound
    {
      content: [
        {
          type: "text",
          text: "User or Game not found"
        }
      ],
      is_error: true
    }
  end
end
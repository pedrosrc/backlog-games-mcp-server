class RateGame
  RATING_RANGE = 0..10

  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])
    game = Game.find(arguments["game_id"])
    rating = Float(arguments["rating"])

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
    error("User or Game not found")
  end

  def self.validate(arguments)
    if arguments["user_id"].blank? || arguments["game_id"].blank? || arguments["rating"].blank?
      return error("`user_id`, `game_id` and `rating` are required")
    end

    rating = Float(arguments["rating"], exception: false)
    return error("`rating` must be a number between #{RATING_RANGE.min} and #{RATING_RANGE.max}") if rating.nil?
    return error("`rating` must be between #{RATING_RANGE.min} and #{RATING_RANGE.max}") unless RATING_RANGE.cover?(rating)

    nil
  end
  private_class_method :validate

  def self.error(message)
    {
      content: [
        {
          type: "text",
          text: message
        }
      ],
      is_error: true
    }
  end
  private_class_method :error
end

class AddToBacklog
  VALID_STATUSES = %w[pending playing completed].freeze

  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])
    game = Game.find(arguments["game_id"])

    backlog_item = BacklogItem.create!(
      user: user,
      game: game,
      status: arguments["status"] || "pending"
    )

    {
      content: [
        {
          type: "text",
          text: "Game `#{game.name}` added to backlog"
        }
      ]
    }
  rescue ActiveRecord::RecordNotFound
    error("User or Game not found")
  end

  def self.validate(arguments)
    return error("`user_id` and `game_id` are required") if arguments["user_id"].blank? || arguments["game_id"].blank?

    if arguments["status"].present? && !VALID_STATUSES.include?(arguments["status"])
      return error("`status` must be one of: #{VALID_STATUSES.join(', ')}")
    end

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

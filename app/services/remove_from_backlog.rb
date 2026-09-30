class RemoveFromBacklog
  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])
    game = Game.find(arguments["game_id"])

    backlog_item = BacklogItem.find_by(user: user, game: game)
    return error("Game `#{game.name}` is not in the backlog") if backlog_item.nil?

    backlog_item.destroy!

    {
      content: [
        {
          type: "text",
          text: "Game `#{game.name}` removed from backlog"
        }
      ]
    }
  rescue ActiveRecord::RecordNotFound
    error("User or Game not found")
  end

  def self.validate(arguments)
    return error("`user_id` and `game_id` are required") if arguments["user_id"].blank? || arguments["game_id"].blank?

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

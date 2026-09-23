class ListBacklog
  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])

    backlog_items = BacklogItem.where(user: user)

    if backlog_items.empty?
      return {
        content: [
          {
            type: "text",
            text: "Backlog is empty for user `#{user.name}`"
          }
        ]
      }
    end

    {
      content: backlog_items.map do |item|
        {
          type: "text",
          text: "Game `#{item.game.name}` - Status: #{item.status}"
        }
      end
    }
  rescue ActiveRecord::RecordNotFound
    error("User not found")
  end

  def self.validate(arguments)
    return error("`user_id` is required") if arguments["user_id"].blank?

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

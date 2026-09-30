class ListBacklog
  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])

    backlog_items = BacklogItem.where(user: user).includes(:game).order(:id)

    if backlog_items.empty?
      return {
        content: [
          {
            type: "text",
            text: "Backlog is empty for user `#{user.name}`"
          }
        ],
        structured_content: { items: [] }
      }
    end

    ratings = Rating.where(user: user).pluck(:game_id, :rating).to_h

    {
      content: backlog_items.map do |item|
        {
          type: "text",
          text: "Game `#{item.game.name}` - Status: #{item.status}"
        }
      end,
      structured_content: {
        items: backlog_items.map do |item|
          { game_id: item.game_id, name: item.game.name, status: item.status, rating: ratings[item.game_id] }
        end
      }
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

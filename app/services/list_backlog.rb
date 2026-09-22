class ListBacklog
  def self.call(arguments)
    user = User.find(arguments["user_id"])
    return if user.blank?

    backlog_items = BacklogItem.where(user: user)

    {
      content: backlog_items.map do |item|
        {
          type: "text",
          text: "Game `#{item.game.name}` - Status: #{item.status}"
        }
      end
    }
  rescue ActiveRecord::RecordNotFound
    {
      content: [
        {
          type: "text",
          text: "User not found"
        }
      ],
      is_error: true
    }
  end
end

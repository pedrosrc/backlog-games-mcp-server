class AddToBacklog
  def self.call(arguments)
    game = Game.find(arguments["game_id"])
    user = User.find(arguments["use_id"])
    return if game.blank? || user.blank?
    
    backlog_item = BacklogItem.create!(
      user: user,
      game: game,
      status: arguments["status"] || "pending"
    )

    {
      content:[
        {
          type: "text",
          text: "Game `#{game.name}` added to backlog"
        }
      ]
    }
  rescue ActiveRecord::RecordNotFound
    {
      content: [
        {
          type: "text",
          text: "Game not found"
        }
      ],
      is_error: true
    }
  end
end
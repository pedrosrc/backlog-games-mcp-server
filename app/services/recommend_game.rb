class RecommendGame
  RECOMMENDATION_LIMIT = 5

  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.find(arguments["user_id"])

    already_in_backlog = BacklogItem.where(user: user).select(:game_id)

    games = Game.where.not(id: already_in_backlog)
                .left_joins(:ratings)
                .group(:id)
                .order(Arel.sql("COALESCE(AVG(ratings.rating), 0) DESC"))
                .limit(RECOMMENDATION_LIMIT)

    if games.empty?
      return {
        content: [
          {
            type: "text",
            text: "No new games to recommend right now, #{user.name}!"
          }
        ]
      }
    end

    {
      content: [
        {
          type: "text",
          text: "Here are some games you might like, #{user.name}: #{games.map(&:name).join(', ')}"
        }
      ]
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

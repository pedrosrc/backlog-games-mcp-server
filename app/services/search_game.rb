class SearchGame
  SEARCH_LIMIT = 10

  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    query = arguments["query"].to_s.strip

    games = Game.where("games.name ILIKE ?", "%#{Game.sanitize_sql_like(query)}%")
                .order(:name)
                .limit(SEARCH_LIMIT)

    if games.empty?
      return {
        content: [
          {
            type: "text",
            text: "No games found for `#{query}`"
          }
        ],
        structured_content: { games: [] }
      }
    end

    {
      content: games.map do |game|
        {
          type: "text",
          text: "Game `#{game.name}` - ID: #{game.id}"
        }
      end,
      structured_content: { games: games.map { |game| { id: game.id, name: game.name } } }
    }
  end

  def self.validate(arguments)
    return error("`query` is required") if arguments["query"].blank?

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

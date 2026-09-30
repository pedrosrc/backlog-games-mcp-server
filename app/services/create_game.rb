class CreateGame
  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    game = Game.create!(name: arguments["name"].to_s.strip)

    {
      content: [
        {
          type: "text",
          text: "Game `#{game.name}` created - ID: #{game.id}"
        }
      ],
      structured_content: { id: game.id, name: game.name }
    }
  end

  def self.validate(arguments)
    return error("`name` is required") if arguments["name"].blank?

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

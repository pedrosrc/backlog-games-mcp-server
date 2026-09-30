class CreateUser
  def self.call(arguments)
    validation_error = validate(arguments)
    return validation_error if validation_error

    user = User.new(name: arguments["name"].to_s.strip, email: arguments["email"].to_s)
    return error(user.errors.full_messages.to_sentence) unless user.save

    {
      content: [
        {
          type: "text",
          text: "User `#{user.name}` created - ID: #{user.id}"
        }
      ],
      structured_content: { id: user.id, name: user.name, email: user.email }
    }
  end

  def self.validate(arguments)
    return error("`name` and `email` are required") if arguments["name"].blank? || arguments["email"].blank?

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

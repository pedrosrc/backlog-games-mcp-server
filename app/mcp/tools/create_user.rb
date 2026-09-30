module Tools
  class CreateUser < MCP::Tool
    tool_name "create_user"
    description "Creates a user and returns its ID"
    input_schema(
      properties: {
        name: {
          type: "string",
          description: "Name of the user"
        },
        email: {
          type: "string",
          description: "Email of the user (unique)"
        }
      },
      required: [ "name", "email" ]
    )

    def self.call(**arguments)
      ServiceResponse.wrap(::CreateUser.call(arguments.stringify_keys))
    end
  end
end

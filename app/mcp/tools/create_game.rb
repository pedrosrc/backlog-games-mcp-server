module Tools
  class CreateGame < MCP::Tool
    tool_name "create_game"
    description "Creates a game and returns its ID"
    input_schema(
      properties: {
        name: {
          type: "string",
          description: "Name of the game"
        }
      },
      required: [ "name" ]
    )

    def self.call(**arguments)
      ServiceResponse.wrap(::CreateGame.call(arguments.stringify_keys))
    end
  end
end

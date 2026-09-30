module Tools
  class AddToBacklog < MCP::Tool
    tool_name "add_to_backlog"
    description "Adds a game to the user's backlog"
    input_schema(
      properties: {
        user_id: {
          type: "integer",
          description: "ID of User"
        },
        game_id: {
          type: "integer",
          description: "ID of the game"
        },
        status: {
          type: "string",
          description: "Initial backlog status",
          enum: [ "pending", "playing", "completed" ]
        }
      },
      required: [ "game_id", "user_id" ]
    )

    def self.call(**arguments)
      ServiceResponse.wrap(::AddToBacklog.call(arguments.stringify_keys))
    end
  end
end

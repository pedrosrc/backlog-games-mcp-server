module Tools
  class RemoveFromBacklog < MCP::Tool
    tool_name "remove_from_backlog"
    description "Removes a game from the user's backlog"
    input_schema(
      properties: {
        user_id: {
          type: "integer",
          description: "ID of User"
        },
        game_id: {
          type: "integer",
          description: "ID of the game"
        }
      },
      required: [ "user_id", "game_id" ]
    )

    def self.call(**arguments)
      ServiceResponse.wrap(::RemoveFromBacklog.call(arguments.stringify_keys))
    end
  end
end

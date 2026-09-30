module Tools
  class RecommendGame < MCP::Tool
    tool_name "recommend_game"
    description "Recommends a game for a user"
    input_schema(
      properties: {
        user_id: {
          type: "integer",
          description: "ID of User"
        }
      },
      required: [ "user_id" ]
    )

    def self.call(**arguments)
      ServiceResponse.wrap(::RecommendGame.call(arguments.stringify_keys))
    end
  end
end

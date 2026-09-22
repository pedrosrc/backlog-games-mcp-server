module Tools
  class RecommendGame < MCP::Tool
    name: "recommend_game",
    description: "Recommends a game for a user",
    input_schema: (
      properties: {
        user_id:{
          type: "integer"
          description: "ID of User"
        }
      },
      required: ["user_id"]
    ) do |arguments|
      RecommendGame.call(arguments)
    end
  end
end
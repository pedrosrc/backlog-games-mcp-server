module Tools
  class RateGame < MCP::Tool
    name: "rate_game",
    description: "Rates a game for a user",
    input_schema: (
      properties: {
        user_id:{
          type: "integer"
          description: "ID of User"
        },
        game_id:{
          type: "integer"
          description: "ID of the game"
        },
        rating: {
          type: "number"
          description: "Rating for the game"
        }
      },
      required: ["user_id", "game_id", "rating"]
    ) do |arguments|
      RateGame.call(arguments)
    end
  end
end
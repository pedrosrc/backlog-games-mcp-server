module Tools
  class SearchGame < MCP::Tool
    tool_name "search_game"
    description "Searches games by name"
    input_schema(
      properties: {
        query: {
          type: "string",
          description: "Text to search in the game name"
        }
      },
      required: [ "query" ]
    )

    def self.call(**arguments)
      ::SearchGame.call(arguments.stringify_keys)
    end
  end
end

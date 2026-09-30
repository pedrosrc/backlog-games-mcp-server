module Tools
  class ListBacklog < MCP::Tool
    tool_name "list_backlog"
    description "Lists the user's backlog"
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
      ServiceResponse.wrap(::ListBacklog.call(arguments.stringify_keys))
    end
  end
end

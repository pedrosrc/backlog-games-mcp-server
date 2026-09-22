module Tools
  class ListBacklog < MCP::Tool
    name: "list_backlog",
    description: "Lists the user's backlog",
    input_schema: (
      properties: {
        user_id:{
          type: "integer"
          description: "ID of User"
        }
      },
      required: ["user_id"]
    ) do |arguments|
      ListBacklog.call(arguments)
    end
  end
end
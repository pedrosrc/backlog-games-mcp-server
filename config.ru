# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# MCP endpoint (Streamable HTTP): http://localhost:3000/mcp
map "/mcp" do
  run McpServer.rack_app
end

map "/" do
  run Rails.application
end

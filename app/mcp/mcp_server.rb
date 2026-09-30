module McpServer
  TOOLS = [
    Tools::CreateUser,
    Tools::CreateGame,
    Tools::SearchGame,
    Tools::AddToBacklog,
    Tools::RemoveFromBacklog,
    Tools::ListBacklog,
    Tools::RateGame,
    Tools::RecommendGame
  ].freeze

  def self.build
    MCP::Server.new(name: "backlog-games", version: "0.1.0", tools: TOOLS)
  end

  def self.rack_app(token: ENV["MCP_AUTH_TOKEN"])
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(build, stateless: true, enable_json_response: true)
    McpAuth.new(transport, token: token)
  end
end

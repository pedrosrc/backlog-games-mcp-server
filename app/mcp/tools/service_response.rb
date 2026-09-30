module Tools
  module ServiceResponse
    def self.wrap(result)
      MCP::Tool::Response.new(
        result[:content],
        error: result[:is_error] || false,
        structured_content: result[:structured_content]
      )
    end
  end
end

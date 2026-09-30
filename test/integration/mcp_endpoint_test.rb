require "test_helper"

class McpEndpointTest < ActiveSupport::TestCase
  HEADERS = {
    "CONTENT_TYPE" => "application/json",
    "HTTP_ACCEPT" => "application/json, text/event-stream"
  }.freeze

  def rpc(app, method, params = {}, headers: {})
    body = { jsonrpc: "2.0", id: 1, method: method, params: params }.to_json
    env = Rack::MockRequest.env_for("/mcp", HEADERS.merge(headers).merge(method: "POST", input: body))
    status, _, response_body = app.call(env)
    text = +""
    response_body.each { |chunk| text << chunk }
    [ status, (JSON.parse(text) rescue nil) ]
  end

  test "lists every tool" do
    status, body = rpc(McpServer.rack_app(token: nil), "tools/list")

    assert_equal 200, status
    assert_equal McpServer::TOOLS.map(&:name_value).sort, body["result"]["tools"].map { |t| t["name"] }.sort
  end

  test "creates a user end to end and returns structured content" do
    _, body = rpc(McpServer.rack_app(token: nil), "tools/call", { name: "create_user", arguments: { name: "Ana", email: "ana@example.com" } })

    assert_equal false, body["result"]["isError"]
    assert_equal User.find_by!(name: "Ana").id, body["result"]["structuredContent"]["id"]
  end

  test "reports tool errors with isError" do
    _, body = rpc(McpServer.rack_app(token: nil), "tools/call", { name: "rate_game", arguments: { user_id: 0, game_id: 0, rating: 5 } })

    assert_equal true, body["result"]["isError"]
  end

  test "requires the bearer token when one is configured" do
    app = McpServer.rack_app(token: "s3cret")

    assert_equal 401, rpc(app, "tools/list").first
    assert_equal 401, rpc(app, "tools/list", headers: { "HTTP_AUTHORIZATION" => "Bearer nope" }).first
    assert_equal 200, rpc(app, "tools/list", headers: { "HTTP_AUTHORIZATION" => "Bearer s3cret" }).first
  end

  test "rejects everything in production when no token is configured" do
    original = Rails.method(:env)
    Rails.define_singleton_method(:env) { ActiveSupport::StringInquirer.new("production") }
    assert_equal 401, rpc(McpServer.rack_app(token: nil), "tools/list").first
  ensure
    Rails.define_singleton_method(:env, original)
  end
end

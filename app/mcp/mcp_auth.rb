class McpAuth
  def initialize(app, token:)
    @app = app
    @token = token.presence
  end

  def call(env)
    return @app.call(env) if authorized?(env)

    body = { error: "Unauthorized" }.to_json
    [ 401, { "content-type" => "application/json", "www-authenticate" => "Bearer" }, [ body ] ]
  end

  private

  def authorized?(env)
    return !Rails.env.production? if @token.nil?

    provided = env["HTTP_AUTHORIZATION"].to_s[/\ABearer (.+)\z/, 1].to_s
    ActiveSupport::SecurityUtils.secure_compare(provided, @token)
  end
end

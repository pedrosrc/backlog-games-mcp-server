ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ResponseAssertions
  def normalize(response)
    return response unless response.is_a?(MCP::Tool::Response)

    { content: response.content, is_error: response.error?, structured_content: response.structured_content }
  end

  def texts(response)
    normalize(response)[:content].map { |c| c[:text] }
  end

  def assert_error(response, message = nil)
    assert normalize(response)[:is_error], "expected an error response, got #{response.inspect}"
    assert_equal message, texts(response).first if message
  end

  def assert_success(response)
    assert_not normalize(response)[:is_error], "expected success, got #{response.inspect}"
  end
end

module ActiveSupport
  class TestCase
    include ResponseAssertions

    def create_user(name: "Ana", email: "#{name.parameterize}-#{SecureRandom.hex(3)}@example.com") = User.create!(name: name, email: email)
    def create_game(name: "Zelda") = Game.create!(name: name)
  end
end

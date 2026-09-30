ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ResponseAssertions
  def texts(response)
    response[:content].map { |c| c[:text] }
  end

  def assert_error(response, message = nil)
    assert response[:is_error], "expected an error response, got #{response.inspect}"
    assert_equal message, texts(response).first if message
  end

  def assert_success(response)
    assert_not response[:is_error], "expected success, got #{response.inspect}"
  end
end

module ActiveSupport
  class TestCase
    include ResponseAssertions

    def create_user(name: "Ana") = User.create!(name: name)
    def create_game(name: "Zelda") = Game.create!(name: name)
  end
end

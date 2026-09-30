require "test_helper"

class CreateUserTest < ActiveSupport::TestCase
  test "creates a user and returns its ID" do
    response = CreateUser.call("name" => "  Ana ", "email" => " Ana@Example.com ")

    user = User.find_by!(name: "Ana")
    assert_success response
    assert_equal [ "User `Ana` created - ID: #{user.id}" ], texts(response)
    assert_equal({ id: user.id, name: "Ana", email: "ana@example.com" }, response[:structured_content])
  end

  test "requires name and email" do
    message = "`name` and `email` are required"

    assert_error CreateUser.call({}), message
    assert_error CreateUser.call("name" => "Ana"), message
    assert_error CreateUser.call("email" => "ana@example.com"), message
    assert_error CreateUser.call("name" => "  ", "email" => "ana@example.com"), message
    assert_equal 0, User.count
  end

  test "rejects an invalid email" do
    response = CreateUser.call("name" => "Ana", "email" => "not-an-email")

    assert_error response, "Email is invalid"
    assert_equal 0, User.count
  end

  test "rejects a duplicate email" do
    CreateUser.call("name" => "Ana", "email" => "ana@example.com")

    assert_error CreateUser.call("name" => "Other", "email" => "ANA@example.com"), "Email has already been taken"
    assert_equal 1, User.count
  end
end

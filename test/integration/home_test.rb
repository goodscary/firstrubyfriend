require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "GET /" do
    get "/"

    assert_select "h1", text: "Hello"
    assert_select "a", text: "Sign in"
  end

  test "signed in GET /" do
    sign_in_as(User.create(email: "andy@goodscary.com", password: "Secret1*3*5*"))
    get "/"

    assert_select "h1", text: "Hello"
    assert_select "p", text: "Signed in as andy@goodscary.com"
  end
end

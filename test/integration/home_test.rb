require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "GET /" do
    get "/"

    assert_select "h1", /Make your first.*rubyfriend.*today/
    assert_select "a", text: "Sign In"
  end

  test "signed in GET /" do
    sign_in_as(User.create(email: "andy@goodscary.com", password: "Secret1*3*5*"))
    get "/"

    assert_redirected_to dashboard_path
  end
end

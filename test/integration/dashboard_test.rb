require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "GET /dashboard" do
    get "/dashboard"

    assert_redirected_to sign_in_path
  end

  test "signed in GET /dashboard" do
    sign_in_as(User.create(email: "andy@goodscary.com", password: "Secret1*3*5*"))
    get "/dashboard"

    assert_select "h1", text: "Dashboard"
  end
end

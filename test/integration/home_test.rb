require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "GET /" do
    get "/"

    assert_select "h1", text: "First Ruby Mentor"
  end
end

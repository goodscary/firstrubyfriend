require "test_helper"

class Sessions::SudosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
    sign_in_as(@user)
  end

  test "should get new" do
    get new_sessions_sudo_path
    assert_response :success
  end

  test "should get new with proceed_to_url parameter" do
    get new_sessions_sudo_path, params: {proceed_to_url: "/dashboard"}
    assert_response :success
  end

  test "should create sudo session with correct password" do
    post sessions_sudo_path, params: {
      password: "Secret1*3*5*",
      proceed_to_url: "/dashboard"
    }

    assert_redirected_to "/dashboard"
  end

  test "should not create sudo session with incorrect password" do
    post sessions_sudo_path, params: {
      password: "wrong_password",
      proceed_to_url: "/dashboard"
    }

    assert_redirected_to new_sessions_sudo_path(proceed_to_url: "/dashboard")
    assert_equal "The password you entered is incorrect", flash[:alert]
  end

  test "should handle missing proceed_to_url" do
    post sessions_sudo_path, params: {
      password: "Secret1*3*5*",
      proceed_to_url: ""
    }

    assert_response :redirect
  end

  test "should require authentication" do
    # Create a new test without signing in
    # Reset session to simulate no authentication
    reset!

    get new_sessions_sudo_path

    # Should redirect to sign in due to authenticate before_action
    assert_response :redirect
  end
end

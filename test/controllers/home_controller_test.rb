require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
  end

  class Index < HomeControllerTest
    test "renders homepage when not signed in" do
      get root_path

      assert_response :success
    end

    test "redirects to dashboard when signed in" do
      sign_in_as(@user)

      get root_path

      assert_redirected_to dashboard_path
    end

    test "treats invalid session cookie as unauthenticated" do
      cookies[:session_token] = "invalid_nonexistent_session_token"

      get root_path

      assert_response :success
    end
  end
end

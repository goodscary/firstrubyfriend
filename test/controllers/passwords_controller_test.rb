require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = sign_in_as(users.basic)
  end

  class Edit < PasswordsControllerTest
    test "renders form" do
      get edit_password_url
      assert_response :success
    end
  end

  class Update < PasswordsControllerTest
    test "updates password with valid params" do
      patch password_url, params: {current_password: "Secret1*3*5*", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}
      assert_redirected_to root_url
    end

    test "rejects wrong current password" do
      patch password_url, params: {current_password: "SecretWrong1*3", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}

      assert_redirected_to edit_password_url
      assert_equal "The current password you entered is incorrect", flash[:alert]
    end

    test "rejects invalid new password" do
      patch password_url, params: {current_password: "Secret1*3*5*", password: "short", password_confirmation: "short"}

      assert_response :unprocessable_entity
    end
  end
end

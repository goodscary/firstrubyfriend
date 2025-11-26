require "test_helper"

class Identity::EmailsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = sign_in_as(users.basic)
  end

  class Edit < Identity::EmailsControllerTest
    test "renders form" do
      get edit_identity_email_url
      assert_response :success
    end
  end

  class Update < Identity::EmailsControllerTest
    test "updates email with valid params" do
      patch identity_email_url, params: {email: "new_email@hey.com", current_password: "Secret1*3*5*"}
      assert_redirected_to root_url
    end

    test "rejects wrong current password" do
      patch identity_email_url, params: {email: "new_email@hey.com", current_password: "SecretWrong1*3"}

      assert_redirected_to edit_identity_email_url
      assert_equal "The password you entered is incorrect", flash[:alert]
    end

    test "rejects invalid email format" do
      patch identity_email_url, params: {email: "invalid-email-format", current_password: "Secret1*3*5*"}

      assert_response :unprocessable_entity
    end

    test "rejects duplicate email" do
      other_user = users.mentor

      patch identity_email_url, params: {email: other_user.email, current_password: "Secret1*3*5*"}

      assert_response :unprocessable_entity
    end

    test "redirects without notice when email is unchanged" do
      patch identity_email_url, params: {email: @user.email, current_password: "Secret1*3*5*"}

      assert_redirected_to root_url
      assert_not_equal "Your email has been changed", flash[:notice]
    end
  end
end

require "test_helper"

class Identity::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(email: "andy@goodscary.com", password: "Secret1*3*5*")
  end

  class New < Identity::PasswordResetsControllerTest
    test "renders form" do
      get new_identity_password_reset_url
      assert_response :success
    end
  end

  class Edit < Identity::PasswordResetsControllerTest
    test "renders form with valid token" do
      sid = @user.password_reset_tokens.create.signed_id(expires_in: 20.minutes)

      get edit_identity_password_reset_url(sid: sid)
      assert_response :success
    end
  end

  class Create < Identity::PasswordResetsControllerTest
    test "sends password reset email to verified user" do
      @user.update(verified: true)

      assert_enqueued_email_with UserMailer.with(user: @user), :password_reset do
        post identity_password_reset_url, params: {email: @user.email}
      end

      assert_redirected_to sign_in_url
    end

    test "rejects nonexistent email" do
      assert_no_enqueued_emails do
        post identity_password_reset_url, params: {email: "invalid_email@hey.com"}
      end

      assert_redirected_to new_identity_password_reset_url
      assert_equal "You can't reset your password until you verify your email", flash[:alert]
    end

    test "rejects unverified email" do
      @user.update! verified: false

      assert_no_enqueued_emails do
        post identity_password_reset_url, params: {email: @user.email}
      end

      assert_redirected_to new_identity_password_reset_url
      assert_equal "You can't reset your password until you verify your email", flash[:alert]
    end
  end

  class Update < Identity::PasswordResetsControllerTest
    test "updates password with valid token" do
      sid = @user.password_reset_tokens.create.signed_id(expires_in: 20.minutes)

      patch identity_password_reset_url, params: {sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}
      assert_redirected_to sign_in_url
    end

    test "rejects expired token" do
      sid_exp = @user.password_reset_tokens.create.signed_id(expires_in: 0.minutes)

      patch identity_password_reset_url, params: {sid: sid_exp, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}
      assert_redirected_to new_identity_password_reset_url
      assert_equal "That password reset link is invalid", flash[:alert]
    end

    test "rejects invalid new password" do
      sid = @user.password_reset_tokens.create.signed_id(expires_in: 20.minutes)

      patch identity_password_reset_url, params: {sid: sid, password: "short", password_confirmation: "short"}
      assert_response :unprocessable_entity
    end
  end
end

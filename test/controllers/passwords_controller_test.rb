require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "pratik@hi.com", password: "password_with_12_chars")
    sign_in_as(@user)
  end

  test "should get edit" do
    get edit_password_url
    assert_response :success
  end

  test "should update password" do
    patch password_url, params: {current_password: "password_with_12_chars", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}
    assert_redirected_to root_url
  end

  test "should not update password with wrong current password" do
    patch password_url, params: {current_password: "SecretWrong1*3", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*"}

    assert_redirected_to edit_password_url
    assert_equal "The current password you entered is incorrect", flash[:alert]
  end
end

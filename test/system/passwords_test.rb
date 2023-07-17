require "application_system_test_case"

class PasswordsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email: "pratik@hi.com", password: "password_with_12_chars")
    sign_in_as(@user)
  end

  test "updating the password" do
    click_on "Change password"

    fill_in "Current password", with: "password_with_12_chars"
    fill_in "New password", with: "Secret6*4*2*"
    fill_in "Confirm new password", with: "Secret6*4*2*"
    click_on "Save changes"

    assert_text "Your password has been changed"
  end
end

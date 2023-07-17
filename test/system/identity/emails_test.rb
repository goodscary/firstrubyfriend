require "application_system_test_case"

class Identity::EmailsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email: "pratik@hi.com", password: "password_with_12_chars")
    sign_in_as(@user)
  end

  test "updating the email" do
    click_on "Change email address"

    fill_in "New email", with: "new_email@hey.com"
    fill_in "Current password", with: "password_with_12_chars"
    click_on "Save changes"

    assert_text "Your email has been changed"
  end

  test "sending a verification email" do
    @user.update! verified: false

    click_on "Change email address"
    click_on "Re-send verification email"

    assert_text "We sent a verification email to your email address"
  end
end

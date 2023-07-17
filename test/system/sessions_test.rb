require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email: "pratik@hi.com", password: "password_with_12_chars")
    sign_in_as(@user)
  end

  test "visiting the index" do
    sign_in_as @user

    click_on "Devices & Sessions"
    assert_selector "h1", text: "Sessions"
  end

  test "signing in" do
    visit sign_in_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password_with_12_chars"
    click_on "Sign in"

    assert_text "Signed in successfully"
  end

  test "signing out" do
    sign_in_as @user

    click_on "Log out"
    assert_text "That session has been logged out"
  end
end

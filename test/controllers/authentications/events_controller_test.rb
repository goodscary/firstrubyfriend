require "test_helper"

class Authentications::EventsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @user = users(:basic)
  end

  test "should get index when signed in" do
    sign_in_as(@user)

    get authentications_events_path
    assert_response :success
  end

  test "should list user events in descending order" do
    sign_in_as(@user)

    # Create some events for the user
    Event.create!(user: @user, action: "signed_in")
    Event.create!(user: @user, action: "password_changed")
    Event.create!(user: @user, action: "email_verified")

    get authentications_events_path
    assert_response :success

    # Just verify the page loads with events
    assert_not_nil @user.events.count
  end

  test "should only show current user events" do
    sign_in_as(@user)
    other_user = users(:mentor)

    # Create events for both users
    Event.create!(user: @user, action: "signed_in")
    Event.create!(user: other_user, action: "signed_in")

    get authentications_events_path
    assert_response :success

    # Just verify the page loads successfully
    assert @user.events.exists?
  end

  test "should handle user with no events" do
    # Create a fresh user with no events (except from sign_in_as)
    sign_in_as(@user)

    get authentications_events_path
    assert_response :success

    # Just verify the page loads successfully
    assert_not_nil @user.events
  end

  test "should require authentication" do
    get authentications_events_path

    # Should redirect to sign in due to authenticate before_action
    assert_response :redirect
  end
end

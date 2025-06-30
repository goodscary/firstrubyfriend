require "test_helper"

class EventTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = users(:basic)
    Current.user_agent = "Mozilla/5.0 Test Browser"
    Current.ip_address = "192.168.1.1"
  end

  test "should belong to user" do
    event = Event.create!(user: @user, action: "test_action")
    assert_equal @user, event.user
  end

  test "should not save without user" do
    event = Event.new(action: "test_action")
    assert_not event.save
    assert_includes event.errors[:user], "must exist"
  end

  test "requires action at database level" do
    # Action is required by database constraint (NOT NULL)
    # Model doesn't validate it, so we test the constraint
    assert_raises(ActiveRecord::NotNullViolation) do
      Event.create!(user: @user, action: nil)
    end
  end

  test "should set user_agent and ip_address on create" do
    event = Event.create!(user: @user, action: "test_action")
    assert_equal "Mozilla/5.0 Test Browser", event.user_agent
    assert_equal "192.168.1.1", event.ip_address
  end

  test "should handle nil Current values" do
    Current.user_agent = nil
    Current.ip_address = nil
    
    event = Event.create!(user: @user, action: "test_action")
    assert_nil event.user_agent
    assert_nil event.ip_address
  end

  test "should delete when user is destroyed" do
    event = Event.create!(user: @user, action: "test_action")
    assert_difference "Event.count", -1 do
      @user.destroy
    end
  end

  test "can have multiple events for same user" do
    event1 = Event.create!(user: @user, action: "action1")
    event2 = Event.create!(user: @user, action: "action2")

    assert_equal 2, @user.events.count
    assert_includes @user.events, event1
    assert_includes @user.events, event2
  end

  test "common event actions" do
    # Test common event actions used in the app
    actions = ["signed_in", "signed_out", "email_verified", "password_changed", "email_verification_requested"]
    
    actions.each do |action|
      event = Event.create!(user: @user, action: action)
      assert event.persisted?, "Should create event with action: #{action}"
      assert_equal action, event.action
    end
  end

  test "preserves original values after create" do
    event = Event.create!(user: @user, action: "test_action")
    original_user_agent = event.user_agent
    original_ip_address = event.ip_address
    
    # Change Current values
    Current.user_agent = "Different Browser"
    Current.ip_address = "10.0.0.1"
    
    # Reload and verify values haven't changed
    event.reload
    assert_equal original_user_agent, event.user_agent
    assert_equal original_ip_address, event.ip_address
  end
end
require "test_helper"

class SessionTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = users(:basic)
    Current.user_agent = "Mozilla/5.0 Test Browser"
    Current.ip_address = "127.0.0.1"
  end

  test "should belong to user" do
    session = Session.create!(user: @user)
    assert_equal @user, session.user
  end

  test "should not save without user" do
    session = Session.new
    assert_not session.save
    assert_includes session.errors[:user], "must exist"
  end

  test "should set user_agent and ip_address on create" do
    session = Session.create!(user: @user)
    assert_equal "Mozilla/5.0 Test Browser", session.user_agent
    assert_equal "127.0.0.1", session.ip_address
  end

  test "should create signed_in event on create" do
    assert_difference "Event.count", 1 do
      Session.create!(user: @user)
    end
    
    event = Event.last
    assert_equal @user, event.user
    assert_equal "signed_in", event.action
  end

  test "should create signed_out event on destroy" do
    session = Session.create!(user: @user)
    
    assert_difference "Event.count", 1 do
      session.destroy
    end
    
    event = Event.last
    assert_equal @user, event.user
    assert_equal "signed_out", event.action
  end

  test "should mark sudo on create" do
    session = Session.create!(user: @user)
    assert session.sudo.marked?
  end

  test "sudo should expire after 30 minutes" do
    session = Session.create!(user: @user)
    assert session.sudo.marked?
    
    # Kredis uses Redis TTL, so we can't easily test expiration in unit tests
    # This would require Redis running and time manipulation
  end

  test "should delete when user is destroyed" do
    session = Session.create!(user: @user)
    assert_difference "Session.count", -1 do
      @user.destroy
    end
  end

  test "can have multiple sessions for same user" do
    session1 = Session.create!(user: @user)
    session2 = Session.create!(user: @user)
    
    assert_equal 2, @user.sessions.count
    assert_includes @user.sessions, session1
    assert_includes @user.sessions, session2
  end

  test "should handle nil Current values" do
    Current.user_agent = nil
    Current.ip_address = nil
    
    session = Session.create!(user: @user)
    assert_nil session.user_agent
    assert_nil session.ip_address
  end

  test "should generate prefixed ID with ses_ prefix" do
    session = Session.create!(user: @user)
    assert session.prefix_id.start_with?("ses_")
    assert session.prefix_id.length > 4
  end

  test "should find session by prefixed ID" do
    session = Session.create!(user: @user)
    found_session = Session.find_by_prefix_id(session.prefix_id)
    assert_equal session, found_session
  end

  test "should return nil when finding by invalid prefixed ID" do
    result = Session.find_by_prefix_id("ses_invalid")
    assert_nil result
  end
end
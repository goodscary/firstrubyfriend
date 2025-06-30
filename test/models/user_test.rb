require "test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = users(:with_location)
  end

  test "should be invalid without email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should be invalid with duplicate email" do
    duplicate_user = @user.dup

    assert_not duplicate_user.valid?
  end

  test "should be invalid with wrong email format" do
    invalid_emails = %w[user@example,com user_at_example.org user.name@example.]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?
    end
  end

  test "should be valid with each preset unsubscribed_reason enum options" do
    valid_reasons = User.unsubscribed_reasons.keys
    valid_reasons.each do |valid_reason|
      @user.unsubscribed_reason = valid_reason
      assert @user.valid?
    end
  end

  test "should not be valid with invalid unsubscribed_reason" do
    assert_raises(ArgumentError) { @user.unsubscribed_reason = "invalid_reason" }
  end

  test "should be valid with valid latitude and longitude" do
    valid_lat = rand(-90..90)
    valid_lng = rand(-180..180)
    @user.lat = valid_lat
    @user.lng = valid_lng

    assert @user.valid?
  end

  test "should not be valid with invalid latitude" do
    @user.lat = 91
    assert_not @user.valid?
  end

  test "should not be valid with invalid longitude" do
    @user.lng = 181
    assert_not @user.valid?
  end
end

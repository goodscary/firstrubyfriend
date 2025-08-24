require "test_helper"

class PasswordResetTokenTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = users(:basic)
    @token = PasswordResetToken.create!(user: @user)
  end

  test "should belong to user" do
    assert_equal @user, @token.user
  end

  test "should not save without user" do
    token = PasswordResetToken.new
    assert_not token.save
    assert_includes token.errors[:user], "must exist"
  end

  test "should be findable by signed id" do
    signed_id = @token.signed_id(purpose: :password_reset)
    found_token = PasswordResetToken.find_signed(signed_id, purpose: :password_reset)
    assert_equal @token, found_token
  end

  test "should return nil for invalid signed id" do
    found_token = PasswordResetToken.find_signed("invalid", purpose: :password_reset)
    assert_nil found_token
  end

  test "should raise error for invalid signed id with bang method" do
    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      PasswordResetToken.find_signed!("invalid", purpose: :password_reset)
    end
  end

  test "should delete when user is destroyed" do
    assert_difference "PasswordResetToken.count", -1 do
      @user.destroy
    end
  end

  test "can have multiple tokens for same user" do
    second_token = PasswordResetToken.create!(user: @user)
    assert_equal 2, @user.password_reset_tokens.count
    assert_includes @user.password_reset_tokens, @token
    assert_includes @user.password_reset_tokens, second_token
  end

  test "signed id should expire" do
    signed_id = @token.signed_id(purpose: :password_reset, expires_in: 0.seconds)
    sleep 0.1
    found_token = PasswordResetToken.find_signed(signed_id, purpose: :password_reset)
    assert_nil found_token
  end

  test "should generate prefixed ID with prt_ prefix" do
    assert @token.prefix_id.start_with?("prt_")
    assert @token.prefix_id.length > 4
  end

  test "should find password reset token by prefixed ID" do
    found_token = PasswordResetToken.find_by_prefix_id(@token.prefix_id)
    assert_equal @token, found_token
  end

  test "should return nil when finding by invalid prefixed ID" do
    result = PasswordResetToken.find_by_prefix_id("prt_invalid")
    assert_nil result
  end
end

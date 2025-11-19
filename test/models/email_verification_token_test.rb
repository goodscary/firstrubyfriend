require "test_helper"

class EmailVerificationTokenTest < ActiveSupport::TestCase
  def setup
    @user = users.basic
    @token = EmailVerificationToken.create!(user: @user)
  end

  test "should belong to user" do
    assert_equal @user, @token.user
  end

  test "should not save without user" do
    token = EmailVerificationToken.new
    assert_not token.save
    assert_includes token.errors[:user], "must exist"
  end

  test "should be findable by signed id" do
    signed_id = @token.signed_id(purpose: :email_verification)
    found_token = EmailVerificationToken.find_signed(signed_id, purpose: :email_verification)
    assert_equal @token, found_token
  end

  test "should return nil for invalid signed id" do
    found_token = EmailVerificationToken.find_signed("invalid", purpose: :email_verification)
    assert_nil found_token
  end

  test "should raise error for invalid signed id with bang method" do
    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      EmailVerificationToken.find_signed!("invalid", purpose: :email_verification)
    end
  end

  test "should delete when user is destroyed" do
    assert_difference "EmailVerificationToken.count", -1 do
      @user.destroy
    end
  end

  test "can have multiple tokens for same user" do
    second_token = EmailVerificationToken.create!(user: @user)
    assert_equal 2, @user.email_verification_tokens.count
    assert_includes @user.email_verification_tokens, @token
    assert_includes @user.email_verification_tokens, second_token
  end

  test "should generate prefixed ID with evt_ prefix" do
    assert @token.prefix_id.start_with?("evt_")
    assert @token.prefix_id.length > 4
  end

  test "should find email verification token by prefixed ID" do
    found_token = EmailVerificationToken.find_by_prefix_id(@token.prefix_id)
    assert_equal @token, found_token
  end

  test "should return nil when finding by invalid prefixed ID" do
    result = EmailVerificationToken.find_by_prefix_id("evt_invalid")
    assert_nil result
  end
end

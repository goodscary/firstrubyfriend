require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users.with_location
    Current.user_agent = "Mozilla/5.0 Test Browser"
    Current.ip_address = "127.0.0.1"
  end

  class Validations < UserTest
    test "rejects nil email" do
      @user.email = nil
      assert_not @user.valid?
    end

    test "rejects duplicate email" do
      duplicate_user = @user.dup
      assert_not duplicate_user.valid?
    end

    test "rejects invalid email format" do
      invalid_emails = %w[user@example,com user_at_example.org user.name@example.]
      invalid_emails.each do |invalid_email|
        @user.email = invalid_email
        assert_not @user.valid?
      end
    end

    test "accepts valid latitude and longitude" do
      valid_lat = rand(-90..90)
      valid_lng = rand(-180..180)
      @user.lat = valid_lat
      @user.lng = valid_lng

      assert @user.valid?
    end

    test "rejects invalid latitude" do
      @user.lat = 91
      assert_not @user.valid?
    end

    test "rejects invalid longitude" do
      @user.lng = 181
      assert_not @user.valid?
    end
  end

  class UnsubscribedReason < UserTest
    test "accepts valid unsubscribed_reason enum options" do
      valid_reasons = User.unsubscribed_reasons.keys
      valid_reasons.each do |valid_reason|
        @user.unsubscribed_reason = valid_reason
        assert @user.valid?
      end
    end

    test "rejects invalid unsubscribed_reason" do
      assert_raises(ArgumentError) { @user.unsubscribed_reason = "invalid_reason" }
    end
  end

  class PrefixedId < UserTest
    test "generates prefixed ID with usr_ prefix" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      assert user.prefix_id.start_with?("usr_")
      assert user.prefix_id.length > 4
    end

    test "finds user by prefixed ID" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      found_user = User.find_by_prefix_id(user.prefix_id)
      assert_equal user, found_user
    end

    test "returns nil for invalid prefixed ID" do
      result = User.find_by_prefix_id("usr_invalid")
      assert_nil result
    end

    test "is stable for same record" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      prefixed_id_1 = user.prefix_id
      user.reload
      prefixed_id_2 = user.prefix_id
      assert_equal prefixed_id_1, prefixed_id_2
    end
  end

  class Callbacks < UserTest
    test "downcases and strips email before validation" do
      user = User.new(email: "  TEST@EXAMPLE.COM  ", password: "SecurePassword123*&^")
      user.valid?
      assert_equal "test@example.com", user.email
    end

    test "sets verified to false when email changes on update" do
      @user.update!(verified: true)
      @user.update!(email: "changed@example.com")

      assert_not @user.verified
    end

    test "creates email_verification_requested event when email changes" do
      @user.update!(email: "newemail@example.com")

      event = Event.last
      assert_equal "email_verification_requested", event.action
      assert_equal @user, event.user
    end

    test "creates password_changed event when password changes" do
      @user.update!(password: "NewSecurePassword123*&^")

      event = Event.last
      assert_equal "password_changed", event.action
      assert_equal @user, event.user
    end

    test "deletes other sessions when password changes" do
      session1 = @user.sessions.create!
      session2 = @user.sessions.create!
      Current.session = session1

      @user.update!(password: "NewSecurePassword123*&^")

      assert Session.exists?(session1.id)
      assert_not Session.exists?(session2.id)
    end

    test "creates email_verified event when verified becomes true" do
      unverified_user = users.unverified
      unverified_user.update!(verified: true)

      event = Event.last
      assert_equal "email_verified", event.action
      assert_equal unverified_user, event.user
    end
  end

  class MentorPredicate < UserTest
    test "returns true when available_as_mentor_at is present" do
      @user.update!(available_as_mentor_at: Time.current)
      assert @user.mentor?
    end

    test "returns true when has mentorship_roles_as_mentor" do
      mentor = users.mentor
      applicant = users.applicant
      Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert mentor.mentor?
    end

    test "returns false when not a mentor" do
      @user.available_as_mentor_at = nil
      assert_not @user.mentor?
    end
  end

  class ApplicantPredicate < UserTest
    test "returns true when requested_mentorship_at is present" do
      @user.update!(requested_mentorship_at: Time.current)
      assert @user.applicant?
    end

    test "returns true when has mentorship_roles_as_applicant" do
      applicant = users.applicant
      mentor = users.mentor
      Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert applicant.applicant?
    end

    test "returns false when not an applicant" do
      @user.requested_mentorship_at = nil
      assert_not @user.applicant?
    end
  end

  class Address < UserTest
    test "returns city and country code" do
      @user.city = "London"
      @user.country_code = "GB"
      assert_equal "London, GB", @user.address
    end

    test "returns only city when country_code is nil" do
      @user.city = "London"
      @user.country_code = nil
      assert_equal "London", @user.address
    end

    test "returns only country_code when city is nil" do
      @user.city = nil
      @user.country_code = "GB"
      assert_equal "GB", @user.address
    end

    test "returns empty string when both nil" do
      @user.city = nil
      @user.country_code = nil
      assert_equal "", @user.address
    end
  end

  class ActiveMentorship < UserTest
    test "returns active_mentor if present" do
      mentor = users.mentor
      applicant = users.applicant
      mentorship = Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert_equal mentorship, mentor.active_mentorship
    end

    test "returns active_applicant if no active mentor" do
      applicant = users.applicant
      mentor = users.mentor
      mentorship = Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert_equal mentorship, applicant.active_mentorship
    end

    test "returns nil when no active mentorship" do
      assert_nil @user.active_mentorship
    end
  end
end

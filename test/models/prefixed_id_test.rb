require "test_helper"

class PrefixedIdTest < ActiveSupport::TestCase
  # Test prefixed ID functionality for User model
  test "user generates prefixed id with usr_ prefix" do
    user = users(:basic)
    assert_prefixed_id_format(user, "usr")
  end

  test "user can be found by prefixed id" do
    user = users(:basic)
    assert_findable_by_prefixed_id(user)
  end

  test "user to_param returns prefixed id for URL generation" do
    user = users(:basic)
    assert user.to_param.start_with?("usr_")
  end

  # Test prefixed ID functionality for Mentorship model
  test "mentorship generates prefixed id with mnt_ prefix" do
    mentorship = mentorships(:active_no_emails_sent)
    assert_prefixed_id_format(mentorship, "mnt")
  end

  test "mentorship can be found by prefixed id" do
    mentorship = mentorships(:active_no_emails_sent)
    assert_findable_by_prefixed_id(mentorship)
  end

  test "mentorship to_param returns prefixed id for URL generation" do
    mentorship = mentorships(:active_no_emails_sent)
    assert mentorship.to_param.start_with?("mnt_")
  end

  # Test prefixed ID functionality for Session model
  test "session generates prefixed id with ses_ prefix" do
    session = sessions(:basic_session)
    assert_prefixed_id_format(session, "ses")
  end

  test "session can be found by prefixed id" do
    session = sessions(:basic_session)
    assert_findable_by_prefixed_id(session)
  end

  # Test prefixed ID functionality for MentorQuestionnaire model
  test "mentor questionnaire generates prefixed id with mqr_ prefix" do
    questionnaire = mentor_questionnaires(:complete_questionnaire)
    assert_prefixed_id_format(questionnaire, "mqr")
  end

  test "mentor questionnaire can be found by prefixed id" do
    questionnaire = mentor_questionnaires(:complete_questionnaire)
    assert_findable_by_prefixed_id(questionnaire)
  end

  # Test prefixed ID functionality for ApplicantQuestionnaire model
  test "applicant questionnaire generates prefixed id with aqr_ prefix" do
    questionnaire = applicant_questionnaires(:applicant_questionnaire)
    assert_prefixed_id_format(questionnaire, "aqr")
  end

  test "applicant questionnaire can be found by prefixed id" do
    questionnaire = applicant_questionnaires(:applicant_questionnaire)
    assert_findable_by_prefixed_id(questionnaire)
  end

  # Test prefixed ID functionality for Event model
  test "event generates prefixed id with evt_ prefix" do
    event = events(:registration_event)
    assert_prefixed_id_format(event, "evt")
  end

  test "event can be found by prefixed id" do
    event = events(:registration_event)
    assert_findable_by_prefixed_id(event)
  end

  # Test prefixed ID functionality for EmailVerificationToken model
  test "email verification token generates prefixed id with evt_ prefix" do
    token = email_verification_tokens(:basic_token)
    assert_prefixed_id_format(token, "evt")
  end

  test "email verification token can be found by prefixed id" do
    token = email_verification_tokens(:basic_token)
    assert_findable_by_prefixed_id(token)
  end

  # Test prefixed ID functionality for PasswordResetToken model
  test "password reset token generates prefixed id with prt_ prefix" do
    token = password_reset_tokens(:basic_reset)
    assert_prefixed_id_format(token, "prt")
  end

  test "password reset token can be found by prefixed id" do
    token = password_reset_tokens(:basic_reset)
    assert_findable_by_prefixed_id(token)
  end

  # Test that prefixed IDs are unique
  test "prefixed ids are unique across instances of same model" do
    users = [users(:basic), users(:mentor)]
    assert_prefixed_id_uniqueness(users)
  end

  # Test error handling
  test "find with invalid prefixed id raises error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      User.find("usr_invalid123")
    end
  end

  test "find with nil prefixed id raises error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      User.find(nil)
    end
  end

  # Test that prefixed IDs work with Rails route helpers
  test "prefixed ids work in route generation" do
    user = users(:basic)
    # Simulate route generation with to_param
    assert user.to_param.start_with?("usr_")
    # The actual route helpers will use this value
  end

  # Test that prefixed IDs persist across database operations
  test "prefixed id remains consistent after reload" do
    user = users(:basic)
    assert_prefixed_id_persistent(user) do
      # No operation, just reload
    end
  end

  test "prefixed id remains consistent after update" do
    user = users(:basic)
    assert_prefixed_id_persistent(user) do
      user.update!(email: "newemail@example.com")
    end
  end

  # Test relationships with prefixed IDs
  test "foreign key relationships work with prefixed ids" do
    mentorship = mentorships(:active_no_emails_sent)
    assert_relationship_with_prefixed_ids(mentorship, :mentor, users(:mentor))
    assert_relationship_with_prefixed_ids(mentorship, :applicant, users(:applicant))
  end

  # Test batch operations with prefixed IDs
  test "batch finding by prefixed ids" do
    user1 = users(:basic)
    user2 = users(:mentor)
    
    prefixed_ids = [user1.to_param, user2.to_param]
    found_users = find_all_by_prefixed_ids(User, prefixed_ids)
    
    assert_includes found_users, user1
    assert_includes found_users, user2
  end

  # Test that prefixed IDs don't interfere with regular ID operations
  test "regular id operations still work alongside prefixed ids" do
    user = users(:basic)
    
    # Regular find by id should still work
    found_by_id = User.find(user.id)
    assert_equal user, found_by_id
    
    # Both should reference the same record
    found_by_prefixed = User.find(user.to_param)
    assert_equal found_by_id, found_by_prefixed
  end
end
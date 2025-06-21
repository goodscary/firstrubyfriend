require "test_helper"

class ActiveApplicantMailerTest < ActionMailer::TestCase
  test "month_1 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_1

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end

  test "month_2 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_2

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end

  test "month_3 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_3

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end

  test "month_4 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_4

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end

  test "month_5 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_5

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end

  test "month_6 sends to mentor's email" do
    mentorship = mentorships(:active_no_emails_sent)
    email = ActiveApplicantMailer.with(mentorship: mentorship).month_6

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [mentorship.applicant.email], email.to
    assert_match mentorship.mentor.email, email.body.encoded
  end
end

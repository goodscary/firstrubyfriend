require "test_helper"

class ActiveApplicantMailerTest < ActionMailer::TestCase
  def setup
    @mentorship = Mentorship.create!(
      mentor: User.create!(email: "mentor-#{SecureRandom.hex(8)}@example.com", password: "Secret1*3*5*", verified: true),
      applicant: User.create!(email: "applicant-#{SecureRandom.hex(8)}@example.com", password: "Secret1*3*5*", verified: true),
      standing: "active"
    )
  end

  test "month_1 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_1

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end

  test "month_2 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_2

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end

  test "month_3 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_3

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end

  test "month_4 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_4

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end

  test "month_5 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_5

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end

  test "month_6 sends to mentor's email" do
    email = ActiveApplicantMailer.with(mentorship: @mentorship).month_6

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@mentorship.applicant.email], email.to
    assert_match @mentorship.mentor.email, email.body.encoded
  end
end

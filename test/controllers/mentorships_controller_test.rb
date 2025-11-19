require "test_helper"

class MentorshipsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
    @mentor = users.mentor
    @applicant = users.applicant
  end

  test "should require authentication" do
    get mentorships_url

    assert_response :redirect
    assert_redirected_to sign_in_path
  end

  test "should get index when signed in" do
    sign_in_as(@user)

    get mentorships_url
    assert_response :success
  end

  test "should display mentorships table" do
    sign_in_as(@user)

    get mentorships_url
    assert_response :success
    assert_select "table"
    assert_select "th", text: "Mentor"
    assert_select "th", text: "Mentee"
    assert_select "th", text: "Standing"
  end

  test "should display mentorship data when mentorships exist" do
    sign_in_as(@user)

    # Create questionnaires for mentor and applicant
    MentorQuestionnaire.create!(
      respondent: @mentor,
      name: "Test Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: true
    )

    ApplicantQuestionnaire.create!(
      respondent: @applicant,
      name: "Test Applicant",
      currently_writing_ruby: true,
      where_started_coding: "Self-taught",
      mentorship_goals: "Learn Ruby",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: true
    )

    # Create a mentorship (or use the seed one)
    mentorship = mentorships.active_no_emails_sent

    get mentorships_url
    assert_response :success
    assert_select "td", text: /Test Mentor/
    assert_select "td", text: /Test Applicant/
    assert_select "span", text: mentorship.standing
  end
end

require "test_helper"

class MatchingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(User.create(email: "andy@goodscary.com", password: "Secret1*3*5*"))

    @applicant = User.create!(email: "test_applicant@example.com", password: "Secret1*3*5*", verified: true)
    mentor = User.create!(email: "test_mentor@example.com", password: "Secret1*3*5*", verified: true)
    ApplicantQuestionnaire.create!(respondent: @applicant, name: "Test Applicant", currently_writing_ruby: true, where_started_coding: "Self-taught", mentorship_goals: "Learn Ruby", looking_for_career_mentorship: true, looking_for_code_mentorship: true)
    MentorQuestionnaire.create!(respondent: mentor, name: "Test Mentor", company_url: "https://example.com", has_mentored_before: true, mentoring_reason: "To help others", preferred_style_career: true, preferred_style_code: true)
    mentor.update!(available_as_mentor_at: Time.current)
  end

  test "should get index" do
    get matching_index_url
    assert_response :success
    assert_select "h2", "Unmatched Applicants"
  end

  test "should get show with matches" do
    get matching_url(@applicant)
    assert_response :success
    assert_select "h2", text: /Matches for/
  end
end

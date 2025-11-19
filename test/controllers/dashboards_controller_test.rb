require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
  end

  test "should get dashboard when signed in" do
    sign_in_as(@user)

    get dashboard_path
    assert_response :success
  end

  test "should load mentor questionnaire if exists" do
    sign_in_as(@user)

    # Create a mentor questionnaire for the user
    MentorQuestionnaire.create!(
      respondent: @user,
      name: "Test Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: false
    )

    get dashboard_path
    assert_response :success
    # Just verify the page loads successfully when questionnaire exists
  end

  test "should load applicant questionnaire if exists" do
    sign_in_as(@user)

    # Create an applicant questionnaire for the user
    ApplicantQuestionnaire.create!(
      respondent: @user,
      name: "Test Applicant",
      currently_writing_ruby: true,
      where_started_coding: "Self-taught",
      mentorship_goals: "Get better at Ruby",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: false
    )

    get dashboard_path
    assert_response :success
    # Just verify the page loads successfully when questionnaire exists
  end

  test "should handle user with no questionnaires" do
    sign_in_as(@user)

    get dashboard_path
    assert_response :success
    # Just verify the page loads successfully when no questionnaires exist
  end

  test "should require authentication" do
    get dashboard_path

    # Should redirect to sign in due to authenticate before_action
    assert_response :redirect
  end
end

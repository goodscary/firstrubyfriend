require "test_helper"

class ApplicantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
    @applicant = users.applicant
  end

  test "should require authentication" do
    get applicants_url

    assert_response :redirect
    assert_redirected_to sign_in_path
  end

  test "should get index when signed in" do
    sign_in_as(@user)

    get applicants_url
    assert_response :success
  end

  test "should display applicants table" do
    sign_in_as(@user)

    get applicants_url
    assert_response :success
    assert_select "table"
    assert_select "th", text: "Name"
    assert_select "th", text: "Email"
    assert_select "th", text: "Location"
  end

  test "should display applicant data when applicants exist" do
    sign_in_as(@user)

    # Create an applicant questionnaire so the applicant shows up
    ApplicantQuestionnaire.create!(
      respondent: @applicant,
      name: "Test Applicant",
      currently_writing_ruby: true,
      where_started_coding: "Self-taught",
      mentorship_goals: "Learn Ruby",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: true
    )

    get applicants_url
    assert_response :success
    assert_select "td", text: "Test Applicant"
    assert_select "td", text: @applicant.email
  end
end

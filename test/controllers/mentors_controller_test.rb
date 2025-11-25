require "test_helper"

class MentorsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
    @mentor = users.mentor
  end

  test "should require authentication" do
    get mentors_url

    assert_response :redirect
    assert_redirected_to sign_in_path
  end

  test "should get index when signed in" do
    sign_in_as(@user)

    get mentors_url
    assert_response :success
  end

  test "should display mentors table" do
    sign_in_as(@user)

    get mentors_url
    assert_response :success
    assert_select "table"
    assert_select "th", text: "Name"
    assert_select "th", text: "Email"
    assert_select "th", text: "Location"
  end

  test "should display mentor data when mentors exist" do
    sign_in_as(@user)

    # Create a mentor questionnaire and mark as available
    MentorQuestionnaire.create!(
      respondent: @mentor,
      name: "Test Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: true
    )
    @mentor.update!(available_as_mentor_at: Time.current)

    get mentors_url
    assert_response :success
    assert_select "td", text: "Test Mentor"
    assert_select "td", text: @mentor.email
  end
end

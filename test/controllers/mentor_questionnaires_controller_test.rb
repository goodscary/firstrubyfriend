require "test_helper"

class MentorQuestionnairesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = sign_in_as(users.basic)
  end

  test "should get new" do
    get new_mentor_questionnaire_url
    assert_response :success
  end

  test "should create mentor questionnaire" do
    assert_difference("MentorQuestionnaire.count") do
      post mentor_questionnaires_url, params: {
        mentor_questionnaire: {
          name: "John Doe",
          company_url: "https://example.com",
          has_mentored_before: true,
          mentoring_reason: "To share knowledge",
          preferred_style_career: true,
          preferred_style_code: false
        },
        user: {
          demographic_year_started_ruby: 2005,
          language: languages.english
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should not create mentor questionnaire with invalid data" do
    assert_no_difference("MentorQuestionnaire.count") do
      post mentor_questionnaires_url, params: {mentor_questionnaire: {name: "", company_url: ""}}
    end
    assert_response :unprocessable_entity
    assert_select "strong", "Please fix the following errors:"
  end
end

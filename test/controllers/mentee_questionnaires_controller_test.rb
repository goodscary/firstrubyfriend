require "test_helper"

class MenteeQuestionnairesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = sign_in_as(User.create(email: "andy@goodscary.com", password: "Secret1*3*5*"))
  end

  test "should get new" do
    get new_mentee_questionnaire_url
    assert_response :success
  end

  test "should create mentee questionnaire" do
    english_language = Language.create!(
      iso639_alpha3: "eng",
      iso639_alpha2: "",
      english_name: "English",
      french_name: "anglais",
      local_name: nil
    )
    assert_difference("MenteeQuestionnaire.count") do
      post mentee_questionnaires_url, params: {
        mentee_questionnaire: {
          name: "John Doe",
          work_url: "https://example.com",
          currently_writing_ruby: true,
          where_started_coding: "Self taught via online resources",
          mentorship_goals: "Learn to be a better developer",
          looking_for_career_mentorship: true,
          looking_for_code_mentorship: false
        },
        user: {
          demographic_year_started_ruby: 2005,
          language: english_language
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should not create mentee questionnaire with invalid data" do
    assert_no_difference("MenteeQuestionnaire.count") do
      post mentee_questionnaires_url, params: {mentee_questionnaire: {name: "", currently_writing_ruby: nil}}
    end
    assert_response :unprocessable_entity
  end
end

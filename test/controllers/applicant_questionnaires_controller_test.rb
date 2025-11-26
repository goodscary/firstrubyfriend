require "test_helper"

class ApplicantQuestionnairesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
    @applicant_user = users.applicant
  end

  class New < ApplicantQuestionnairesControllerTest
    test "requires authentication" do
      get new_applicant_questionnaire_path
      assert_response :redirect
    end

    test "renders form when user has no questionnaire" do
      sign_in_as(@user)

      get new_applicant_questionnaire_path
      assert_response :success
    end

    test "redirects when user already has questionnaire" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      get new_applicant_questionnaire_path
      assert_redirected_to edit_applicant_questionnaire_path(questionnaire)
    end
  end

  class Create < ApplicantQuestionnairesControllerTest
    test "requires authentication" do
      post applicant_questionnaires_path, params: valid_questionnaire_params
      assert_response :redirect
    end

    test "creates questionnaire with valid params" do
      sign_in_as(@user)

      assert_difference "ApplicantQuestionnaire.count", 1 do
        post applicant_questionnaires_path, params: valid_questionnaire_params
      end

      assert_redirected_to root_path
      assert_equal "Your Mentee Questionnaire answers have been saved", flash[:notice]
    end

    test "renders form with errors for invalid params" do
      sign_in_as(@user)

      assert_no_difference "ApplicantQuestionnaire.count" do
        post applicant_questionnaires_path, params: invalid_questionnaire_params
      end

      assert_response :unprocessable_entity
    end

    test "updates user with user params" do
      sign_in_as(@user)

      post applicant_questionnaires_path, params: valid_questionnaire_params_with_user_data(
        city: "New York",
        country_code: "US"
      )

      assert_redirected_to root_path
      @user.reload
      assert_equal "New York", @user.city
      assert_equal "US", @user.country_code
    end
  end

  class Edit < ApplicantQuestionnairesControllerTest
    test "requires authentication" do
      questionnaire = create_questionnaire_for(@user)
      reset!

      get edit_applicant_questionnaire_path(questionnaire)
      assert_response :redirect
    end

    test "renders form for questionnaire owner" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      get edit_applicant_questionnaire_path(questionnaire)
      assert_response :success
    end
  end

  class Update < ApplicantQuestionnairesControllerTest
    test "requires authentication" do
      questionnaire = create_questionnaire_for(@user)
      reset!

      patch applicant_questionnaire_path(questionnaire), params: valid_questionnaire_params
      assert_response :redirect
    end

    test "updates questionnaire with valid params" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch applicant_questionnaire_path(questionnaire), params: {
        applicant_questionnaire: {
          name: "Updated Name",
          currently_writing_ruby: true,
          where_started_coding: "Updated location",
          mentorship_goals: "Updated goals",
          looking_for_career_mentorship: true,
          looking_for_code_mentorship: false
        },
        user: {
          city: "Test City",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      assert_equal "Your Mentee Questionnaire has been updated.", flash[:notice]

      questionnaire.reload
      assert_equal "Updated Name", questionnaire.name
    end

    test "renders form with errors for invalid params" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch applicant_questionnaire_path(questionnaire), params: {
        applicant_questionnaire: {
          name: "",
          currently_writing_ruby: nil,
          where_started_coding: "",
          mentorship_goals: "",
          looking_for_career_mentorship: nil,
          looking_for_code_mentorship: nil
        },
        user: {
          city: "Test City",
          country_code: "US"
        }
      }

      assert_response :unprocessable_entity
    end

    test "updates user when user params are different" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch applicant_questionnaire_path(questionnaire), params: {
        applicant_questionnaire: {
          name: questionnaire.name,
          currently_writing_ruby: questionnaire.currently_writing_ruby,
          where_started_coding: questionnaire.where_started_coding,
          mentorship_goals: questionnaire.mentorship_goals,
          looking_for_career_mentorship: questionnaire.looking_for_career_mentorship,
          looking_for_code_mentorship: questionnaire.looking_for_code_mentorship
        },
        user: {
          city: "Los Angeles",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      @user.reload
      assert_equal "Los Angeles", @user.city
      assert_equal "US", @user.country_code
    end

    test "does not update user when user params are same as existing" do
      @user.update!(city: "Chicago", country_code: "US")
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch applicant_questionnaire_path(questionnaire), params: {
        applicant_questionnaire: {
          name: questionnaire.name,
          currently_writing_ruby: questionnaire.currently_writing_ruby,
          where_started_coding: questionnaire.where_started_coding,
          mentorship_goals: questionnaire.mentorship_goals,
          looking_for_career_mentorship: questionnaire.looking_for_career_mentorship,
          looking_for_code_mentorship: questionnaire.looking_for_code_mentorship
        },
        user: {
          city: "Chicago",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      @user.reload
      assert_equal "Chicago", @user.city
    end
  end

  private

  def create_questionnaire_for(user)
    ApplicantQuestionnaire.create!(
      respondent: user,
      name: "Test Applicant",
      currently_writing_ruby: true,
      where_started_coding: "Self-taught",
      mentorship_goals: "Learn Ruby best practices",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: false
    )
  end

  def valid_questionnaire_params
    {
      applicant_questionnaire: {
        name: "New Applicant",
        currently_writing_ruby: true,
        where_started_coding: "Bootcamp",
        mentorship_goals: "Career guidance",
        looking_for_career_mentorship: true,
        looking_for_code_mentorship: true
      },
      user: {
        city: "Test City",
        country_code: "US"
      }
    }
  end

  def valid_questionnaire_params_with_user_data(city:, country_code:)
    {
      applicant_questionnaire: {
        name: "New Applicant",
        currently_writing_ruby: true,
        where_started_coding: "Bootcamp",
        mentorship_goals: "Career guidance",
        looking_for_career_mentorship: true,
        looking_for_code_mentorship: true
      },
      user: {
        city: city,
        country_code: country_code
      }
    }
  end

  def invalid_questionnaire_params
    {
      applicant_questionnaire: {
        name: "",
        currently_writing_ruby: nil,
        where_started_coding: "",
        mentorship_goals: "",
        looking_for_career_mentorship: nil,
        looking_for_code_mentorship: nil
      },
      user: {
        city: "Test City",
        country_code: "US"
      }
    }
  end
end

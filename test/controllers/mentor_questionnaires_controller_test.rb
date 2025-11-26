require "test_helper"

class MentorQuestionnairesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users.basic
  end

  class New < MentorQuestionnairesControllerTest
    test "requires authentication" do
      get new_mentor_questionnaire_path
      assert_response :redirect
    end

    test "renders form when user has no questionnaire" do
      sign_in_as(@user)

      get new_mentor_questionnaire_path
      assert_response :success
    end

    test "redirects when user already has questionnaire" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      get new_mentor_questionnaire_path
      assert_redirected_to edit_mentor_questionnaire_path(questionnaire)
    end
  end

  class Create < MentorQuestionnairesControllerTest
    test "requires authentication" do
      post mentor_questionnaires_path, params: valid_questionnaire_params
      assert_response :redirect
    end

    test "creates questionnaire with valid params" do
      sign_in_as(@user)

      assert_difference "MentorQuestionnaire.count", 1 do
        post mentor_questionnaires_path, params: valid_questionnaire_params
      end

      assert_redirected_to root_path
      assert_equal "Your Mentor Questionnaire answers have been saved", flash[:notice]
    end

    test "renders form with errors for invalid params" do
      sign_in_as(@user)

      assert_no_difference "MentorQuestionnaire.count" do
        post mentor_questionnaires_path, params: invalid_questionnaire_params
      end

      assert_response :unprocessable_entity
    end

    test "updates user with user params" do
      sign_in_as(@user)

      post mentor_questionnaires_path, params: valid_questionnaire_params_with_user_data(
        city: "San Francisco",
        country_code: "US",
        demographic_year_started_ruby: 2015
      )

      assert_redirected_to root_path
      @user.reload
      assert_equal "San Francisco", @user.city
      assert_equal "US", @user.country_code
      assert_equal 2015, @user.demographic_year_started_ruby
    end
  end

  class Edit < MentorQuestionnairesControllerTest
    test "requires authentication" do
      questionnaire = create_questionnaire_for(@user)
      reset!

      get edit_mentor_questionnaire_path(questionnaire)
      assert_response :redirect
    end

    test "renders form for questionnaire owner" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      get edit_mentor_questionnaire_path(questionnaire)
      assert_response :success
    end
  end

  class Update < MentorQuestionnairesControllerTest
    test "requires authentication" do
      questionnaire = create_questionnaire_for(@user)
      reset!

      patch mentor_questionnaire_path(questionnaire), params: valid_questionnaire_params
      assert_response :redirect
    end

    test "updates questionnaire with valid params" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch mentor_questionnaire_path(questionnaire), params: {
        mentor_questionnaire: {
          name: "Updated Name",
          company_url: "https://updated.example.com",
          has_mentored_before: false,
          mentoring_reason: "Updated reason",
          preferred_style_career: false,
          preferred_style_code: true
        },
        user: {
          city: "Test City",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      assert_equal "Your Mentor Questionnaire has been updated.", flash[:notice]

      questionnaire.reload
      assert_equal "Updated Name", questionnaire.name
    end

    test "renders form with errors for invalid params" do
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch mentor_questionnaire_path(questionnaire), params: {
        mentor_questionnaire: {
          name: "",
          company_url: "",
          has_mentored_before: nil,
          mentoring_reason: ""
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

      patch mentor_questionnaire_path(questionnaire), params: {
        mentor_questionnaire: {
          name: questionnaire.name,
          company_url: questionnaire.company_url,
          has_mentored_before: questionnaire.has_mentored_before,
          mentoring_reason: questionnaire.mentoring_reason,
          preferred_style_career: questionnaire.preferred_style_career,
          preferred_style_code: questionnaire.preferred_style_code
        },
        user: {
          city: "Boston",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      @user.reload
      assert_equal "Boston", @user.city
      assert_equal "US", @user.country_code
    end

    test "does not update user when user params are same as existing" do
      @user.update!(city: "Seattle", country_code: "US")
      questionnaire = create_questionnaire_for(@user)
      sign_in_as(@user)

      patch mentor_questionnaire_path(questionnaire), params: {
        mentor_questionnaire: {
          name: questionnaire.name,
          company_url: questionnaire.company_url,
          has_mentored_before: questionnaire.has_mentored_before,
          mentoring_reason: questionnaire.mentoring_reason,
          preferred_style_career: questionnaire.preferred_style_career,
          preferred_style_code: questionnaire.preferred_style_code
        },
        user: {
          city: "Seattle",
          country_code: "US"
        }
      }

      assert_redirected_to root_path
      @user.reload
      assert_equal "Seattle", @user.city
    end
  end

  private

  def create_questionnaire_for(user)
    MentorQuestionnaire.create!(
      respondent: user,
      name: "Test Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others learn Ruby",
      preferred_style_career: true,
      preferred_style_code: false
    )
  end

  def valid_questionnaire_params
    {
      mentor_questionnaire: {
        name: "New Mentor",
        company_url: "https://newmentor.com",
        has_mentored_before: true,
        mentoring_reason: "I want to give back to the community",
        preferred_style_career: true,
        preferred_style_code: true
      },
      user: {
        city: "New York",
        country_code: "US"
      }
    }
  end

  def valid_questionnaire_params_with_user_data(city:, country_code:, demographic_year_started_ruby:)
    {
      mentor_questionnaire: {
        name: "New Mentor",
        company_url: "https://newmentor.com",
        has_mentored_before: true,
        mentoring_reason: "I want to give back to the community",
        preferred_style_career: true,
        preferred_style_code: true
      },
      user: {
        city: city,
        country_code: country_code,
        demographic_year_started_ruby: demographic_year_started_ruby
      }
    }
  end

  def invalid_questionnaire_params
    {
      mentor_questionnaire: {
        name: "",
        company_url: "",
        has_mentored_before: nil,
        mentoring_reason: ""
      },
      user: {
        city: "Test City",
        country_code: "US"
      }
    }
  end
end

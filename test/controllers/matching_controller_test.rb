require "test_helper"

class MatchingControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = sign_in_as(users.basic)

    @applicant = users.applicant
    @mentor = users.mentor
    ApplicantQuestionnaire.find_or_create_by!(respondent: @applicant) do |q|
      q.name = "Test Applicant"
      q.currently_writing_ruby = true
      q.where_started_coding = "Self-taught"
      q.mentorship_goals = "Learn Ruby"
      q.looking_for_career_mentorship = true
      q.looking_for_code_mentorship = true
    end
    MentorQuestionnaire.find_or_create_by!(respondent: @mentor) do |q|
      q.name = "Test Mentor"
      q.company_url = "https://example.com"
      q.has_mentored_before = true
      q.mentoring_reason = "To help others"
      q.preferred_style_career = true
      q.preferred_style_code = true
    end
    @mentor.update!(available_as_mentor_at: Time.current)
  end

  class Index < MatchingControllerTest
    test "renders unmatched applicants" do
      get matching_index_url
      assert_response :success
      assert_select "h2", "Unmatched Applicants"
    end
  end

  class Show < MatchingControllerTest
    test "renders matches for applicant" do
      get matching_url(@applicant)
      assert_response :success
      assert_select "h2", text: /Matches for/
    end
  end

  class Create < MatchingControllerTest
    test "creates mentorship with valid params" do
      Mentorship.where(applicant: @applicant, mentor: @mentor).destroy_all

      assert_difference "Mentorship.count", 1 do
        post matching_index_url, params: {
          applicant_id: @applicant.id,
          mentor_id: @mentor.id
        }
      end

      assert_redirected_to matching_index_path
      assert_equal "Match created successfully!", flash[:notice]
    end

    test "fails when mentor and applicant are the same" do
      assert_no_difference "Mentorship.count" do
        post matching_index_url, params: {
          applicant_id: @applicant.id,
          mentor_id: @applicant.id
        }
      end

      assert_response :unprocessable_entity
    end
  end
end

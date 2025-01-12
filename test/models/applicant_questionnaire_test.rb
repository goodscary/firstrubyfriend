require "test_helper"

class ApplicantQuestionnaireTest < ActiveSupport::TestCase
  def setup
    @applicant_questionnaire = ApplicantQuestionnaire.new(
      respondent: create_user,
      name: "Pratik",
      work_url: "https://example.com",
      currently_writing_ruby: true,
      where_started_coding: "Self taught via online resources",
      mentorship_goals: "To get a job",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: false
    )
  end

  test "name should be present" do
    @applicant_questionnaire.name = nil
    assert_not @applicant_questionnaire.valid?
  end

  test "currently_writing_ruby should be present" do
    @applicant_questionnaire.currently_writing_ruby = nil
    assert_not @applicant_questionnaire.valid?
  end

  test "where_started_coding should be present" do
    @applicant_questionnaire.where_started_coding = nil
    assert_not @applicant_questionnaire.valid?
  end

  test "mentorship_goals should be present" do
    @applicant_questionnaire.mentorship_goals = nil
    assert_not @applicant_questionnaire.valid?
  end

  test "looking_for_career_mentorship should be present" do
    @applicant_questionnaire.looking_for_career_mentorship = nil
    assert_not @applicant_questionnaire.valid?
  end

  test "looking_for_code_mentorship should be present" do
    @applicant_questionnaire.looking_for_code_mentorship = nil
    assert_not @applicant_questionnaire.valid?
  end
end

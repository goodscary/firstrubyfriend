require "test_helper"

class MentorQuestionnaireTest < ActiveSupport::TestCase
  def setup
    @user = create_user
    @mentor_questionnaire = MentorQuestionnaire.new(
      respondent: @user,
      name: "Andy Croll",
      company_url: "https://example.com",
      year_started_ruby: 2005,
      country: "UK",
      city: "Brighton",
      has_mentored_before: true,
      mentoring_reason: "To give back to the community",
      preferred_style_career: true,
      preferred_style_code: false
    )
  end

  test "name should be present" do
    @mentor_questionnaire.name = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "company_url should be present" do
    @mentor_questionnaire.company_url = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "year_started_ruby should be present" do
    @mentor_questionnaire.year_started_ruby = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "country should be present" do
    @mentor_questionnaire.country = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "city should be present" do
    @mentor_questionnaire.city = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "has_mentored_before should be present" do
    @mentor_questionnaire.has_mentored_before = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "mentoring_reason should be present" do
    @mentor_questionnaire.mentoring_reason = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "preferred_style_career should be present" do
    @mentor_questionnaire.preferred_style_career = nil
    assert_not @mentor_questionnaire.valid?
  end

  test "preferred_style_code should be present" do
    @mentor_questionnaire.preferred_style_code = nil
    assert_not @mentor_questionnaire.valid?
  end
end

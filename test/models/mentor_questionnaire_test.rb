require "test_helper"

class MentorQuestionnaireTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = users(:basic)
    @mentor_questionnaire = @user.build_mentor_questionnaire(
      name: "Andy Croll",
      company_url: "https://example.com",
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
    assert_raises(ActiveRecord::NotNullViolation) do
      @mentor_questionnaire.save
    end
  end

  test "preferred_style_code should be present" do
    @mentor_questionnaire.preferred_style_code = nil

    assert_raises(ActiveRecord::NotNullViolation) do
      @mentor_questionnaire.save
    end
  end

  test "should generate prefixed ID with mqr_ prefix" do
    @mentor_questionnaire.save!
    assert @mentor_questionnaire.prefix_id.start_with?("mqr_")
    assert @mentor_questionnaire.prefix_id.length > 4
  end

  test "should find mentor questionnaire by prefixed ID" do
    @mentor_questionnaire.save!
    found_questionnaire = MentorQuestionnaire.find_by_prefix_id(@mentor_questionnaire.prefix_id)
    assert_equal @mentor_questionnaire, found_questionnaire
  end

  test "should return nil when finding by invalid prefixed ID" do
    result = MentorQuestionnaire.find_by_prefix_id("mqr_invalid")
    assert_nil result
  end
end

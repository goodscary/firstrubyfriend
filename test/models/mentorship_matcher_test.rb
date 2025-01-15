require "test_helper"

class MentorshipMatcherTest < ActiveSupport::TestCase
  BOURNEMOUTH = [50.7192, -1.8808]
  BRIGHTON = [50.8225, -0.1372]
  BERLIN = [52.5200, 13.4050]
  NEW_YORK = [40.7128, -74.0060]

  def setup
    @english = Language.create!(iso639_alpha3: "eng", english_name: "English")
    @french = Language.create!(iso639_alpha3: "fra", english_name: "French")
    @applicant = setup_applicant
    @best_mentor = setup_best_mentor
    @medium_mentor = setup_medium_mentor
    @lowest_mentor = setup_lowest_mentor
  end

  test "should find and rank matches based on the matching criteria" do
    matches = Mentorship.find_matches_for_applicant(@applicant)

    assert_equal 3, matches.length, "Should find all three mentors"

    # Best mentor (Brighton/Bournemouth, both languages, both preferences)
    assert_equal @best_mentor, matches[0][0], "Best mentor should be first"
    assert_equal 100, matches[0][1], "Best mentor should have 100 points"

    # Medium mentor (Berlin, one language, one preference)
    assert_equal @medium_mentor, matches[1][0], "Medium mentor should be second"
    assert_equal 65, matches[1][1], "Medium mentor should have 65 points"

    # Lowest mentor (New York, one language, no preferences)
    assert_equal @lowest_mentor, matches[2][0], "Lowest mentor should be last"
    assert_equal 45, matches[2][1], "Lowest mentor should have 45 points"
  end

  private

  def setup_applicant
    user = User.create!(
      email: "applicant@example.com",
      password: "Secret1*3*5*",
      verified: true,
      lat: BOURNEMOUTH[0],
      lng: BOURNEMOUTH[1]
    )
    user.languages << @english
    ApplicantQuestionnaire.create!(
      respondent: user,
      name: "Test Applicant",
      currently_writing_ruby: true,
      where_started_coding: "Self-taught",
      mentorship_goals: "Learn Ruby",
      looking_for_career_mentorship: true,
      looking_for_code_mentorship: true
    )
    user
  end

  def setup_best_mentor
    user = User.create!(
      email: "best_mentor@example.com",
      password: "Secret1*3*5*",
      verified: true,
      lat: BRIGHTON[0],
      lng: BRIGHTON[1],
      available_as_mentor_at: Time.current
    )
    user.languages << [@english, @french]
    MentorQuestionnaire.create!(
      respondent: user,
      name: "Best Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: true
    )
    user
  end

  def setup_medium_mentor
    user = User.create!(
      email: "medium_mentor@example.com",
      password: "Secret1*3*5*",
      verified: true,
      lat: BERLIN[0],
      lng: BERLIN[1],
      available_as_mentor_at: Time.current
    )
    user.languages << @english
    MentorQuestionnaire.create!(
      respondent: user,
      name: "Medium Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: false
    )
    user
  end

  def setup_lowest_mentor
    user = User.create!(
      email: "lowest_mentor@example.com",
      password: "Secret1*3*5*",
      verified: true,
      lat: NEW_YORK[0],
      lng: NEW_YORK[1],
      available_as_mentor_at: Time.current
    )
    user.languages << @english
    MentorQuestionnaire.create!(
      respondent: user,
      name: "Lowest Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: false,
      preferred_style_code: false
    )
    user
  end
end

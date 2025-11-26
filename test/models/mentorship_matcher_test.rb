require "test_helper"

class MentorshipMatcherTest < ActiveSupport::TestCase
  def setup
    @english = languages.english
    @french = Language.create!(iso639_alpha3: "fra", iso639_alpha2: "fr", english_name: "French", french_name: "francais", local_name: "Francais")
    @hindi = Language.create!(iso639_alpha3: "hin", iso639_alpha2: "hi", english_name: "Hindi", french_name: "hindi", local_name: "Hindi")
    @applicant = setup_applicant
  end

  class FindMatchesForApplicant < MentorshipMatcherTest
    test "finds and ranks matches based on the matching criteria" do
      best_mentor = setup_best_mentor
      medium_mentor = setup_medium_mentor
      lowest_mentor = setup_lowest_mentor
      matches = Mentorship.find_matches_for_applicant(@applicant)

      assert_equal 3, matches.length, "Should find three mentors"

      # Best mentor: same country + same timezone + both prefs
      # 40 (country) + 30 (distance) + 30 (prefs) = 100
      assert_equal best_mentor, matches[0][0], "Best mentor should be first"
      assert_equal 100, matches[0][1], "Best mentor should have 100 points"

      # Medium mentor: different country + near timezone + 1 pref
      # 0 + 10 + 15 = 25
      assert_equal medium_mentor, matches[1][0], "Medium mentor should be second"
      assert_equal 25, matches[1][1], "Medium mentor should have 25 points"

      # Lowest mentor: different country + distant timezone + no prefs
      # 0 + 5 + 0 = 5
      assert_equal lowest_mentor, matches[2][0], "Lowest mentor should be last"
      assert_equal 5, matches[2][1], "Lowest mentor should have 5 points"
    end

    test "excludes mentors without language match" do
      invalid_mentor = setup_invalid_mentor
      matches = Mentorship.find_matches_for_applicant(@applicant)

      assert invalid_mentor.mentor_questionnaire, "Mentor questionnarie exists"
      refute_includes matches.map(&:first), invalid_mentor, "Mentor without shared language should be excluded"
    end

    test "handles applicant without location" do
      applicant_no_location = setup_applicant_without_location
      setup_mentor_without_location

      matches = Mentorship.find_matches_for_applicant(applicant_no_location)

      # Should still match, but with distance nil (long_distance score)
      assert_not_empty matches, "Should still find matches without location"
    end

    test "handles mentor without location" do
      mentor_no_location = setup_mentor_without_location

      matches = Mentorship.find_matches_for_applicant(@applicant)

      # Mentor without location should still be included
      mentor_match = matches.find { |m, _| m == mentor_no_location }
      assert mentor_match, "Mentor without location should still match"
    end

    test "handles applicant without questionnaire" do
      applicant_no_questionnaire = User.create!(
        email: "no_questionnaire@example.com",
        password: "Secret1*3*5*",
        verified: true
      )
      applicant_no_questionnaire.languages << @english

      matches = Mentorship.find_matches_for_applicant(applicant_no_questionnaire)

      assert_empty matches, "Should return no matches when applicant has no questionnaire"
    end

    test "handles mentor without questionnaire" do
      # This case is handled by the available_mentors scope which joins on mentor_questionnaire
      # So mentors without questionnaires won't be included in the results
      mentor_no_questionnaire = User.create!(
        email: "mentor_no_quest@example.com",
        password: "Secret1*3*5*",
        verified: true,
        available_as_mentor_at: Time.current
      )
      mentor_no_questionnaire.languages << @english

      matches = Mentorship.find_matches_for_applicant(@applicant)

      refute_includes matches.map(&:first), mentor_no_questionnaire
    end

    test "gives remote preference score when distance is nil" do
      applicant_no_geo = setup_applicant_without_location
      mentor_no_geo = User.create!(
        email: "remote_mentor@example.com",
        password: "Secret1*3*5*",
        verified: true,
        country_code: "GB", # Same country as applicant
        available_as_mentor_at: Time.current
      )
      mentor_no_geo.languages << @english
      MentorQuestionnaire.create!(
        respondent: mentor_no_geo,
        name: "Remote Mentor",
        company_url: "https://example.com",
        has_mentored_before: true,
        mentoring_reason: "To help others",
        preferred_style_career: true,
        preferred_style_code: true
      )

      matches = Mentorship.find_matches_for_applicant(applicant_no_geo)
      mentor_match = matches.find { |m, _| m == mentor_no_geo }

      # Applicant has no country_code, mentor has GB
      # Country match: 0 (different country since nil != GB)
      # Without geocoding: 5 (long distance) + 10 (2 prefs * 5 remote score) = 15
      assert_equal 15, mentor_match[1], "Should use remote preference score"
    end
  end

  private

  def setup_applicant
    user = User.create!(
      email: "applicant-#{SecureRandom.hex(8)}@example.com",
      password: "Secret1*3*5*",
      verified: true,
      city: "Bournemouth",
      country_code: "GB"
    )
    user.languages << [@english, @french]
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

  def setup_applicant_without_location
    user = User.create!(
      email: "applicant-no-loc-#{SecureRandom.hex(8)}@example.com",
      password: "Secret1*3*5*",
      verified: true
      # No city, country_code, lat, lng
    )
    user.languages << @english
    ApplicantQuestionnaire.create!(
      respondent: user,
      name: "Test Applicant No Location",
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
      city: "Brighton",
      country_code: "GB",
      available_as_mentor_at: Time.current
    )
    user.languages << [@english]
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
      city: "Paris",
      country_code: "FR",
      available_as_mentor_at: Time.current
    )
    user.languages << @french
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
      city: "New York",
      country_code: "US",
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

  def setup_invalid_mentor
    user = User.create!(
      email: "invalid_mentor@example.com",
      password: "Secret1*3*5*",
      verified: true,
      city: "Bournemouth",
      country_code: "GB",
      available_as_mentor_at: Time.current
    )
    user.languages << @hindi
    MentorQuestionnaire.create!(
      respondent: user,
      name: "Invalid Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: false,
      preferred_style_code: false
    )
    user
  end

  def setup_mentor_without_location
    user = User.create!(
      email: "mentor_no_loc_#{SecureRandom.hex(8)}@example.com",
      password: "Secret1*3*5*",
      verified: true,
      available_as_mentor_at: Time.current
    )
    user.languages << @english
    MentorQuestionnaire.create!(
      respondent: user,
      name: "No Location Mentor",
      company_url: "https://example.com",
      has_mentored_before: true,
      mentoring_reason: "To help others",
      preferred_style_career: true,
      preferred_style_code: true
    )
    user
  end
end

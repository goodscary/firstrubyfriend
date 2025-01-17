class MentorshipMatcher
  LANGUAGE_MATCH_SCORE = 40
  LOCAL_PREFERENCE_SCORE = 15
  REMOTE_PREFERENCE_SCORE = 5
  DISTANCE_SCORES = {
    (0..300) => 30,        # Same timezone
    (301..1000) => 10      # Near timezone (+/- 1-2 hours)
  }.freeze
  LONG_DISTANCE_SCORE = 5  # Distant timezone

  def initialize(applicant)
    @applicant = applicant
    @applicant_languages = applicant.languages
    @applicant_questionnaire = applicant.applicant_questionnaire
  end

  def matches
    scored_mentors = available_mentors.map do |mentor|
      [mentor, calculate_match_score(mentor)]
    end

    scored_mentors.sort_by { |_, score| -score }
  end

  private

  attr_reader :applicant, :applicant_languages, :applicant_questionnaire

  def available_mentors
    Mentorship.available_mentors.includes(:languages, :mentor_questionnaire)
  end

  # Calculates match score (max 100 points) based on:
  # 1. Languages: 40 points for any shared language
  # 2. Location: 30 points same timezone, 10 points near timezone (+/-2h), 5 points distant timezone
  # 3. Preferences: Each matching preference (code/career)
  #    - 15 points if in same/near timezone
  #    - 5 points if in distant timezone
  def calculate_match_score(mentor)
    @mentor = mentor
    @mentor_questionnaire = mentor.mentor_questionnaire
    return 0 unless valid_for_matching?

    total_score = 0
    distance = calculate_distance

    total_score += LANGUAGE_MATCH_SCORE if languages_match?
    total_score += calculate_distance_score(distance)
    total_score += calculate_preference_score(distance)

    total_score
  end

  def valid_for_matching?
    applicant && applicant_languages && applicant_questionnaire && @mentor && @mentor_questionnaire
  end

  def calculate_distance
    return nil unless @mentor.lat && @mentor.lng && applicant.lat && applicant.lng

    Geocoder::Calculations.distance_between(
      [@mentor.lat, @mentor.lng],
      [applicant.lat, applicant.lng]
    )
  end

  def calculate_distance_score(distance)
    return LONG_DISTANCE_SCORE if distance.nil?

    matching_score = DISTANCE_SCORES.find do |range, score|
      range.include?(distance)
    end&.last

    matching_score || LONG_DISTANCE_SCORE
  end

  def languages_match?
    (@mentor.languages & applicant_languages).any?
  end

  def calculate_preference_score(distance)
    preference_score = 0

    preference_value = (distance <= 1000) ? LOCAL_PREFERENCE_SCORE : REMOTE_PREFERENCE_SCORE

    if career_preference_match?
      preference_score += preference_value
    end

    if code_preference_match?
      preference_score += preference_value
    end

    preference_score
  end

  def career_preference_match?
    @mentor.mentor_questionnaire.preferred_style_career &&
      applicant_questionnaire.looking_for_career_mentorship
  end

  def code_preference_match?
    @mentor.mentor_questionnaire.preferred_style_code &&
      applicant_questionnaire.looking_for_code_mentorship
  end
end

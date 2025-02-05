class MentorshipMatcher
  COUNTRY_MATCH_SCORE = 40
  LOCAL_PREFERENCE_SCORE = 15
  REMOTE_PREFERENCE_SCORE = 5
  DISTANCE_SCORES = {
    (0..300) => 30,      # Same timezone
    (301..1000) => 10,   # Near timezone (+/- 1-2 hours)
    :long_distance => 5  # Distant timezone
  }.freeze

  def initialize(applicant)
    @applicant = applicant
    @applicant_languages = applicant.languages
    @applicant_questionnaire = applicant.applicant_questionnaire
  end

  def matches
    User.available_mentors
      .includes(:languages, :mentor_questionnaire)
      .filter_map { |mentor| match_score_for(mentor) }
      .sort_by { |_, score| -score }
  end

  private

  attr_reader :applicant, :applicant_languages, :applicant_questionnaire

  # Calculates match score (max 100 points) based on:
  # 1. Country: 40 points for same country
  # 2. Location: 30 points same timezone, 10 points near timezone (+/-2h), 5 points distant timezone
  # 3. Preferences: Each matching preference (code/career)
  #    - 15 points if in same/near timezone
  #    - 5 points if in distant timezone

  def match_score_for(mentor)
    return unless valid_match?(mentor)
    return unless language_match?(mentor)

    distance = calculate_distance(mentor)

    score = country_score(mentor) +
      distance_score(distance) +
      preference_score(mentor, distance)

    [mentor, score]
  end

  def valid_match?(mentor)
    applicant &&
      mentor &&
      applicant_questionnaire &&
      mentor.mentor_questionnaire
  end

  def country_score(mentor)
    (mentor.country_code == applicant.country_code) ? COUNTRY_MATCH_SCORE : 0
  end

  def language_match?(mentor)
    (mentor.languages & applicant_languages).any?
  end

  def calculate_distance(mentor)
    return unless geocoded?(mentor) && geocoded?(applicant)

    Geocoder::Calculations.distance_between(
      [mentor.lat, mentor.lng],
      [applicant.lat, applicant.lng]
    )
  end

  def geocoded?(user)
    user.lat.present? && user.lng.present?
  end

  def distance_score(distance)
    return DISTANCE_SCORES[:long_distance] if distance.nil?

    matching_score = DISTANCE_SCORES.find do |range, score|
      range.is_a?(Range) && range.include?(distance)
    end&.last

    matching_score || DISTANCE_SCORES[:long_distance]
  end

  def preference_score(mentor, distance)
    base_score = (distance.present? && distance <= 1000) ?
                 LOCAL_PREFERENCE_SCORE :
                 REMOTE_PREFERENCE_SCORE

    scores = []
    scores << base_score if career_match?(mentor)
    scores << base_score if code_match?(mentor)
    scores.sum
  end

  def career_match?(mentor)
    mentor.mentor_questionnaire.preferred_style_career &&
      applicant_questionnaire.looking_for_career_mentorship
  end

  def code_match?(mentor)
    mentor.mentor_questionnaire.preferred_style_code &&
      applicant_questionnaire.looking_for_code_mentorship
  end
end

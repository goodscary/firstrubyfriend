module User::Matchable
  extend ActiveSupport::Concern

  def best_mentor_match
    matches = MentorshipMatcher.new(self).matches
    return nil if matches.empty?

    excluded_mentor_ids = previously_rejected_mentor_ids
    eligible_matches = matches.reject { |mentor, _| excluded_mentor_ids.include?(mentor.id) }

    return nil if eligible_matches.empty?

    eligible_matches.first
  end

  private

  def previously_rejected_mentor_ids
    Mentorship.where(applicant: self, standing: :rejected).pluck(:mentor_id)
  end
end

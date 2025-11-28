class AutoMatchService
  attr_reader :matches_created, :errors

  def initialize(options = {})
    @minimum_score = options[:minimum_score] || 30
    @matches_created = []
    @errors = []
  end

  def run
    unmatched_applicants.each do |applicant|
      create_best_match(applicant)
    end

    {
      success: errors.empty?,
      matches_created: matches_created.size,
      errors: errors,
      matches: matches_created
    }
  end

  private

  attr_reader :minimum_score

  def unmatched_applicants
    User.unmatched_applicants
  end

  def available_mentors_for(applicant)
    matcher = MentorshipMatcher.new(applicant)
    matcher.matches
  end

  def create_best_match(applicant)
    matches = available_mentors_for(applicant)

    return if matches.empty?

    best_mentor, best_score = matches.first

    if best_score < minimum_score
      errors << {
        applicant_email: applicant.email,
        error: "Best match score (#{best_score}) below minimum threshold (#{minimum_score})"
      }
      return
    end

    mentorship = Mentorship.new(
      applicant: applicant,
      mentor: best_mentor,
      standing: "pending_approval"
    )

    if mentorship.save
      matches_created << {
        mentorship_id: mentorship.id,
        applicant_email: applicant.email,
        mentor_email: best_mentor.email,
        score: best_score
      }
    else
      errors << {
        applicant_email: applicant.email,
        error: mentorship.errors.full_messages.join(", ")
      }
    end
  end
end

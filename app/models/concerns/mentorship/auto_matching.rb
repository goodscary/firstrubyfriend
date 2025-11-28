module Mentorship::AutoMatching
  extend ActiveSupport::Concern

  class_methods do
    def auto_match_all(minimum_score: 30)
      matches_created = []
      errors = []

      User.unmatched_applicants.each do |applicant|
        result = create_match_for(applicant, minimum_score: minimum_score)

        if result[:success]
          matches_created << result[:match]
        elsif result[:error]
          errors << result[:error]
        end
      end

      {
        success: errors.empty?,
        matches_created: matches_created.size,
        errors: errors,
        matches: matches_created
      }
    end

    private

    def create_match_for(applicant, minimum_score:)
      best_mentor, best_score = applicant.best_mentor_match

      return {success: false} unless best_mentor

      if best_score < minimum_score
        return {
          success: false,
          error: {
            applicant_email: applicant.email,
            error: "Best match score (#{best_score}) below minimum threshold (#{minimum_score})"
          }
        }
      end

      mentorship = new(
        applicant: applicant,
        mentor: best_mentor,
        standing: "pending"
      )

      if mentorship.save
        {
          success: true,
          match: {
            mentorship_id: mentorship.id,
            applicant_email: applicant.email,
            mentor_email: best_mentor.email,
            score: best_score
          }
        }
      else
        {
          success: false,
          error: {
            applicant_email: applicant.email,
            error: mentorship.errors.full_messages.join(", ")
          }
        }
      end
    end
  end
end

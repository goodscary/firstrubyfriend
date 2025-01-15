class Mentorship < ApplicationRecord
  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum :standing, %w[active ended].index_by(&:itself)

  scope :active, -> { where(standing: :active) }
  scope :available_mentors, -> {
    User.joins(:mentor_questionnaire)
      .where.not(available_as_mentor_at: nil)
      .where.not(id: active.select(:mentor_id))
  }

  validates :standing, presence: true
  validate :mentor_and_applicant_cannot_be_same

  def self.find_matches_for_applicant(applicant)
    MentorshipMatcher.new(applicant).matches
  end

  private

  def mentor_and_applicant_cannot_be_same
    errors.add(:mentor, "cannot be the same as applicant") if mentor == applicant
  end
end

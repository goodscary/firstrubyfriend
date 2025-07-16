class Mentorship < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true
  ulid :mentor_id
  ulid :applicant_id

  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum :standing, %w[active ended].index_by(&:itself)

  scope :active, -> { where(standing: :active) }

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

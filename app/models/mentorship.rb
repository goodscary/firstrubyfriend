class Mentorship < ApplicationRecord
  include AutoMatching

  has_prefix_id :mnt

  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum :standing, %w[pending active ended].index_by(&:itself)

  scope :pending, -> { where(standing: :pending) }
  scope :active, -> { where(standing: :active) }
  scope :active_or_pending, -> { where(standing: [:pending, :active]) }

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

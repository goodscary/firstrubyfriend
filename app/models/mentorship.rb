class Mentorship < ApplicationRecord
  has_prefix_id :mnt

  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum :standing, %w[pending_approval active ended].index_by(&:itself)

  scope :pending_approval, -> { where(standing: :pending_approval) }
  scope :active, -> { where(standing: :active) }
  scope :active_or_pending, -> { where(standing: [:pending_approval, :active]) }

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

class Mentorship < ApplicationRecord
  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum standing: {
    active: "active",
    ended: "ended"
  }

  validates :standing, presence: true
  validate :mentor_and_applicant_cannot_be_same

  private

  def mentor_and_applicant_cannot_be_same
    errors.add(:mentor, "cannot be the same as applicant") if mentor == applicant
  end
end

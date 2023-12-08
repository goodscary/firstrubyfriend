class MentorQuestionnaire < ApplicationRecord
  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :company_url, presence: true
  validates :has_mentored_before, presence: true
  validates :mentoring_reason, presence: true

  accepts_nested_attributes_for :respondent
end

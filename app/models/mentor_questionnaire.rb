class MentorQuestionnaire < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true
  ulid :respondent_id

  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :company_url, presence: true
  validates :has_mentored_before, inclusion: [true, false]
  validates :mentoring_reason, presence: true
end

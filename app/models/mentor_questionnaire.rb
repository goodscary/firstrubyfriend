class MentorQuestionnaire < ApplicationRecord
  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :company_url, presence: true
  validates :year_started_ruby, presence: true
  validates :has_mentored_before, presence: true
  validates :mentoring_reason, presence: true
  validates :preferred_style_career, presence: true
  validates :preferred_style_code, presence: true
end

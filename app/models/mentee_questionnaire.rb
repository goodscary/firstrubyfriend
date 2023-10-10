class MenteeQuestionnaire < ApplicationRecord
  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :currently_writing_ruby, presence: true
  validates :where_started_coding, presence: true
  validates :mentorship_goals, presence: true
  validates :looking_for_career_mentorship, presence: true
  validates :looking_for_code_mentorship, presence: true
end

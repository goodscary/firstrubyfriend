class MenteeQuestionnaire < ApplicationRecord
  include ULID::Rails
  ulid :id, auto_generate: true
  ulid :respondent_id

  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :currently_writing_ruby, inclusion: [true, false]
  validates :where_started_coding, presence: true
  validates :mentorship_goals, presence: true
  validates :looking_for_career_mentorship, inclusion: [true, false]
  validates :looking_for_code_mentorship, inclusion: [true, false]
end

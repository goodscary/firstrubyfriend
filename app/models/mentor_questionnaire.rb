class MentorQuestionnaire < ApplicationRecord
  has_prefix_id :mqr

  belongs_to :respondent, class_name: "User", foreign_key: "respondent_id"

  validates :respondent_id, presence: true
  validates :name, presence: true
  validates :company_url, presence: true
  validates :has_mentored_before, inclusion: [true, false]
  validates :mentoring_reason, presence: true

  after_create_commit :subscribe_to_mailcoach

  private

  def subscribe_to_mailcoach
    SubscribeToMailcoachJob.perform_later(respondent_id, "mentor")
  end
end

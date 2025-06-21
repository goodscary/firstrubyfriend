module Mentorship::EmailDelivery
  extend ActiveSupport::Concern

  included do
    scope :ready_for_email_1, -> { active.where(applicant_month_1_email_sent_at: nil) }
    scope :ready_for_email_2, -> { sent_email_1.where(applicant_month_2_email_sent_at: nil) }
    scope :ready_for_email_3, -> { sent_email_2.where(applicant_month_3_email_sent_at: nil) }
    scope :ready_for_email_4, -> { sent_email_3.where(applicant_month_4_email_sent_at: nil) }
    scope :ready_for_email_5, -> { sent_email_4.where(applicant_month_5_email_sent_at: nil) }
    scope :ready_for_email_6, -> { sent_email_5.where(applicant_month_6_email_sent_at: nil) }
    scope :sent_email_1, -> { active.where.not(applicant_month_1_email_sent_at: nil) }
    scope :sent_email_2, -> { sent_email_1.where.not(applicant_month_2_email_sent_at: nil) }
    scope :sent_email_3, -> { sent_email_2.where.not(applicant_month_3_email_sent_at: nil) }
    scope :sent_email_4, -> { sent_email_3.where.not(applicant_month_4_email_sent_at: nil) }
    scope :sent_email_5, -> { sent_email_4.where.not(applicant_month_5_email_sent_at: nil) }
    scope :sent_email_6, -> { sent_email_5.where.not(applicant_month_6_email_sent_at: nil) }
  end

  def send_email_1
    touch(:applicant_month_1_email_sent_at, :mentor_month_1_email_sent_at)
    deliver_email_1
  end
end

class SubscribeToMailcoachJob < ApplicationJob
  queue_as :default

  retry_on MailcoachClient::ApiError, wait: :polynomially_longer, attempts: 5

  def perform(user_id, user_type)
    user = User.find_by(id: user_id)
    return unless user

    result = MailcoachSubscriptionService.new(user, user_type: user_type).subscribe

    if result[:success]
      Rails.logger.info("Subscribed #{user.email} to Mailcoach as #{user_type}")
    elsif result[:skipped]
      Rails.logger.info("Mailcoach subscription skipped for #{user.email}: #{result[:reason]}")
    else
      Rails.logger.error("Failed to subscribe #{user.email} to Mailcoach: #{result[:error]}")
    end
  end
end

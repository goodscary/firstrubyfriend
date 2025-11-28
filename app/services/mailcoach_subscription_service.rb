class MailcoachSubscriptionService
  attr_reader :user, :user_type

  def initialize(user, user_type:)
    @user = user
    @user_type = user_type.to_s
  end

  def subscribe
    return {skipped: true, reason: "Mailcoach not configured"} unless client_configured?

    result = client.subscribe(
      email: user.email,
      first_name: user_first_name,
      last_name: user_last_name,
      tags: build_tags
    )

    if result[:already_subscribed]
      {success: true, already_subscribed: true}
    else
      {success: true, data: result}
    end
  rescue MailcoachClient::ConfigurationError => e
    Rails.logger.warn("Mailcoach subscription skipped: #{e.message}")
    {skipped: true, reason: e.message}
  rescue MailcoachClient::ApiError => e
    Rails.logger.error("Mailcoach subscription failed for #{user.email}: #{e.message}")
    {success: false, error: e.message}
  end

  def self.subscribe_mentor(user)
    new(user, user_type: :mentor).subscribe
  end

  def self.subscribe_applicant(user)
    new(user, user_type: :applicant).subscribe
  end

  private

  def client
    @client ||= MailcoachClient.new
  end

  def client_configured?
    MailcoachClient.new.configured?
  rescue MailcoachClient::ConfigurationError
    false
  end

  def user_first_name
    user.first_name.presence || questionnaire_name&.split&.first
  end

  def user_last_name
    user.last_name.presence || questionnaire_name&.split&.drop(1)&.join(" ")
  end

  def questionnaire_name
    case user_type
    when "mentor"
      user.mentor_questionnaire&.name
    when "applicant"
      user.applicant_questionnaire&.name
    end
  end

  def build_tags
    tags = ["firstrubyfriend", user_type]
    tags << user.country_code.downcase if user.country_code.present?
    tags
  end
end

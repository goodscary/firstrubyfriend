class MailcoachClient < ApplicationClient
  # API client for Mailcoach email marketing platform
  # https://www.mailcoach.app/api-documentation/endpoints/subscribers/
  #
  # Configure in Rails credentials:
  #   mailcoach:
  #     api_url: https://yourapp.mailcoach.app/api
  #     api_token: your-api-token
  #     list_uuid: your-list-uuid
  #
  # Example usage:
  #
  #   client = MailcoachClient.new
  #   client.find("user@example.com")
  #   client.add("user@example.com", first_name: "Jane", last_name: "Doe")
  #   client.remove("user@example.com")

  class MissingCredentials < Error; end

  attr_reader :email_list_uuid

  def initialize(token: credentials.api_token, email_list_uuid: credentials.list_uuid, api_url: credentials.api_url)
    super(token:)
    @email_list_uuid = email_list_uuid
    @api_url = api_url
  end

  def find(email)
    get(subscribers_path, query: {"filter[email]" => email}).data.first
  rescue *NET_HTTP_ERRORS
    raise Error, "Unable to find subscriber"
  end

  def add(email, first_name: nil, last_name: nil, tags: nil, extra_attributes: nil)
    body = {email:, first_name:, last_name:, tags:, extra_attributes:}.compact

    post(subscribers_path, body:).data
  rescue *NET_HTTP_ERRORS
    raise Error, "Unable to add subscriber"
  end

  def remove(email)
    find(email)&.tap { |subscriber| delete(subscriber_path(subscriber.uuid)) }
  rescue *NET_HTTP_ERRORS
    raise Error, "Unable to remove subscriber"
  end

  def find_or_add(email, **)
    find(email) || add(email, **)
  end

  def base_uri = @api_url

  private

  def subscribers_path = "/email-lists/#{email_list_uuid}/subscribers"

  def subscriber_path(uuid) = "/subscribers/#{uuid}"

  def credentials
    Rails.application.credentials.mailcoach || raise(MissingCredentials, "Missing mailcoach credentials")
  end
end

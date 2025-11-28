class MailcoachClient
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ApiError < Error
    attr_reader :status, :response_body

    def initialize(message, status: nil, response_body: nil)
      super(message)
      @status = status
      @response_body = response_body
    end
  end

  API_TIMEOUT = 30

  def initialize
    @api_url = mailcoach_config[:api_url]
    @api_token = mailcoach_config[:api_token]
    @list_uuid = mailcoach_config[:list_uuid]

    validate_configuration!
  end

  def subscribe(email:, first_name: nil, last_name: nil, tags: [])
    payload = {
      email: email,
      first_name: first_name,
      last_name: last_name,
      tags: Array(tags)
    }.compact

    post("/api/email-lists/#{@list_uuid}/subscribers", payload)
  end

  def unsubscribe(email:)
    delete("/api/email-lists/#{@list_uuid}/subscribers/#{email}")
  end

  def find_subscriber(email:)
    get("/api/email-lists/#{@list_uuid}/subscribers/#{email}")
  rescue ApiError => e
    return nil if e.status == 404
    raise
  end

  def configured?
    @api_url.present? && @api_token.present? && @list_uuid.present?
  end

  private

  def mailcoach_config
    {
      api_url: ENV["MAILCOACH_API_URL"] || Rails.application.credentials.dig(:mailcoach, :api_url),
      api_token: ENV["MAILCOACH_API_TOKEN"] || Rails.application.credentials.dig(:mailcoach, :api_token),
      list_uuid: ENV["MAILCOACH_LIST_UUID"] || Rails.application.credentials.dig(:mailcoach, :list_uuid)
    }
  end

  def validate_configuration!
    return if configured?

    missing = []
    missing << "MAILCOACH_API_URL" unless @api_url.present?
    missing << "MAILCOACH_API_TOKEN" unless @api_token.present?
    missing << "MAILCOACH_LIST_UUID" unless @list_uuid.present?

    raise ConfigurationError, "Missing Mailcoach configuration: #{missing.join(", ")}"
  end

  def get(path)
    request(:get, path)
  end

  def post(path, payload)
    request(:post, path, payload)
  end

  def delete(path)
    request(:delete, path)
  end

  def request(method, path, payload = nil)
    uri = URI.parse("#{@api_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = API_TIMEOUT
    http.open_timeout = API_TIMEOUT

    request = build_request(method, uri, payload)
    response = http.request(request)

    handle_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise ApiError.new("Mailcoach API timeout: #{e.message}")
  rescue => e
    raise ApiError.new("Mailcoach API error: #{e.message}")
  end

  def build_request(method, uri, payload)
    request = case method
    when :get
      Net::HTTP::Get.new(uri.request_uri)
    when :post
      Net::HTTP::Post.new(uri.request_uri)
    when :delete
      Net::HTTP::Delete.new(uri.request_uri)
    end

    request["Authorization"] = "Bearer #{@api_token}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"

    if payload
      request.body = payload.to_json
    end

    request
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      response.body.present? ? JSON.parse(response.body) : {}
    when 422
      body = begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        {}
      end
      if body.dig("errors", "email")&.include?("This email address is already subscribed")
        return {already_subscribed: true}
      end
      raise ApiError.new(
        "Validation failed: #{body["message"] || body}",
        status: response.code.to_i,
        response_body: body
      )
    else
      raise ApiError.new(
        "Mailcoach API error: #{response.code} - #{response.body}",
        status: response.code.to_i,
        response_body: response.body
      )
    end
  end
end

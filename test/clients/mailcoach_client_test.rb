require "test_helper"

class MailcoachClientTest < ActiveSupport::TestCase
  setup do
    @api_token = "test-api-token"
    @email_list_uuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    @subscriber_uuid = "f9e8d7c6-b5a4-3210-fedc-ba0987654321"
    @base_url = "https://firstrubyfriend.mailcoach.app/api"
    @client = MailcoachClient.new(token: @api_token, email_list_uuid: @email_list_uuid, api_url: @base_url)
  end

  class FindTest < MailcoachClientTest
    test "find returns subscriber when found" do
      response_body = {
        data: [{uuid: @subscriber_uuid, email: "jane@example.com", first_name: "Jane"}]
      }.to_json

      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "jane@example.com"}
        )
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})

      subscriber = @client.find("jane@example.com")
      assert_equal "jane@example.com", subscriber.email
      assert_equal "Jane", subscriber.first_name
    end

    test "find returns nil when not found" do
      response_body = {data: []}.to_json

      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "notfound@example.com"}
        )
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})

      subscriber = @client.find("notfound@example.com")
      assert_nil subscriber
    end
  end

  class AddTest < MailcoachClientTest
    test "add creates a new subscriber" do
      response_body = {
        data: {uuid: @subscriber_uuid, email: "new@example.com", first_name: "New", last_name: "User"}
      }.to_json

      stub_request(:post, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}", "Content-Type" => "application/json"},
          body: {email: "new@example.com", first_name: "New", last_name: "User"}.to_json
        )
        .to_return(status: 201, body: response_body, headers: {"Content-Type" => "application/json"})

      subscriber = @client.add("new@example.com", first_name: "New", last_name: "User")
      assert_equal "new@example.com", subscriber.email
      assert_equal "New", subscriber.first_name
    end

    test "add with tags" do
      response_body = {
        data: {uuid: @subscriber_uuid, email: "tagged@example.com", tags: ["mentor", "ruby"]}
      }.to_json

      stub_request(:post, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}", "Content-Type" => "application/json"},
          body: {email: "tagged@example.com", tags: ["mentor", "ruby"]}.to_json
        )
        .to_return(status: 201, body: response_body, headers: {"Content-Type" => "application/json"})

      subscriber = @client.add("tagged@example.com", tags: ["mentor", "ruby"])
      assert_includes subscriber.tags, "mentor"
    end

    test "add with only email" do
      response_body = {
        data: {uuid: @subscriber_uuid, email: "simple@example.com"}
      }.to_json

      stub_request(:post, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}", "Content-Type" => "application/json"},
          body: {email: "simple@example.com"}.to_json
        )
        .to_return(status: 201, body: response_body, headers: {"Content-Type" => "application/json"})

      subscriber = @client.add("simple@example.com")
      assert_equal "simple@example.com", subscriber.email
    end
  end

  class RemoveTest < MailcoachClientTest
    test "remove deletes subscriber by email" do
      # First request: find subscriber
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "remove@example.com"}
        )
        .to_return(status: 200, body: {data: [{uuid: @subscriber_uuid, email: "remove@example.com"}]}.to_json, headers: {"Content-Type" => "application/json"})

      # Second request: delete subscriber
      stub_request(:delete, "#{@base_url}/subscribers/#{@subscriber_uuid}")
        .with(headers: {"Authorization" => "Bearer #{@api_token}"})
        .to_return(status: 204, body: "", headers: {})

      subscriber = @client.remove("remove@example.com")
      assert_equal "remove@example.com", subscriber.email
    end

    test "remove returns nil when subscriber not found" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "notfound@example.com"}
        )
        .to_return(status: 200, body: {data: []}.to_json, headers: {"Content-Type" => "application/json"})

      result = @client.remove("notfound@example.com")
      assert_nil result
    end
  end

  class FindOrAddTest < MailcoachClientTest
    test "find_or_add returns existing subscriber when found" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "existing@example.com"}
        )
        .to_return(status: 200, body: {data: [{uuid: @subscriber_uuid, email: "existing@example.com", first_name: "Existing"}]}.to_json, headers: {"Content-Type" => "application/json"})

      subscriber = @client.find_or_add("existing@example.com", first_name: "Different")
      assert_equal "Existing", subscriber.first_name
    end

    test "find_or_add creates subscriber when not found" do
      # First request: find subscriber (not found)
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}"},
          query: {"filter[email]" => "new@example.com"}
        )
        .to_return(status: 200, body: {data: []}.to_json, headers: {"Content-Type" => "application/json"})

      # Second request: create subscriber
      stub_request(:post, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(
          headers: {"Authorization" => "Bearer #{@api_token}", "Content-Type" => "application/json"},
          body: {email: "new@example.com", first_name: "New"}.to_json
        )
        .to_return(status: 201, body: {data: {uuid: @subscriber_uuid, email: "new@example.com", first_name: "New"}}.to_json, headers: {"Content-Type" => "application/json"})

      subscriber = @client.find_or_add("new@example.com", first_name: "New")
      assert_equal "new@example.com", subscriber.email
      assert_equal "New", subscriber.first_name
    end
  end

  class ErrorHandlingTest < MailcoachClientTest
    test "raises Unauthorized for 401 response" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(query: {"filter[email]" => "test@example.com"})
        .to_return(status: 401, body: "Unauthorized", headers: {})

      assert_raises(ApplicationClient::Unauthorized) do
        @client.find("test@example.com")
      end
    end

    test "raises NotFound for 404 response" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(query: {"filter[email]" => "test@example.com"})
        .to_return(status: 404, body: "Not Found", headers: {})

      assert_raises(ApplicationClient::NotFound) do
        @client.find("test@example.com")
      end
    end

    test "raises RateLimit for 429 response" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(query: {"filter[email]" => "test@example.com"})
        .to_return(status: 429, body: "Rate limit exceeded", headers: {})

      assert_raises(ApplicationClient::RateLimit) do
        @client.find("test@example.com")
      end
    end

    test "raises Error for network errors" do
      stub_request(:get, "#{@base_url}/email-lists/#{@email_list_uuid}/subscribers")
        .with(query: {"filter[email]" => "test@example.com"})
        .to_timeout

      assert_raises(MailcoachClient::Error) do
        @client.find("test@example.com")
      end
    end
  end

  class InitializationTest < MailcoachClientTest
    test "accepts all parameters in constructor" do
      client = MailcoachClient.new(token: "custom-token", email_list_uuid: "custom-uuid", api_url: "https://custom.mailcoach.app/api")
      assert_equal "custom-uuid", client.email_list_uuid
      assert_equal "https://custom.mailcoach.app/api", client.base_uri
    end

    test "raises MissingCredentials when credentials not configured" do
      assert_raises(MailcoachClient::MissingCredentials) do
        MailcoachClient.new
      end
    end
  end
end

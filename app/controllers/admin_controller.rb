class AdminController < ApplicationController
  skip_before_action :authenticate

  before_action :authenticate_admin!

  private

  def authenticate_admin!
    authenticate_or_request_with_http_basic("Admin") do |username, password|
      expected_username = Rails.application.credentials.dig(:admin, :username)
      expected_password = Rails.application.credentials.dig(:admin, :password)

      ActiveSupport::SecurityUtils.secure_compare(username, expected_username.to_s) &
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password.to_s)
    end
  end
end

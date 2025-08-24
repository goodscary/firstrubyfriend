# SimpleCov must be started before any of your application code is loaded
if ENV["RAILS_ENV"] == "test"
  require "simplecov"
  SimpleCov.start "rails" do
    # Add coverage groups
    add_group "Models", "app/models"
    add_group "Controllers", "app/controllers"
    add_group "Helpers", "app/helpers"
    add_group "Mailers", "app/mailers"
    add_group "Jobs", "app/jobs"
    add_group "Channels", "app/channels"

    # Add filters to exclude files from coverage
    add_filter "/test/"
    add_filter "/config/"
    add_filter "/vendor/"
    add_filter "/db/"

    # Set minimum coverage percentage
    minimum_coverage 80  # Commented out temporarily to analyze coverage

    # Use multiple formatters
    if ENV["CI"]
      formatter SimpleCov::Formatter::SimpleFormatter
    else
      formatter SimpleCov::Formatter::HTMLFormatter
    end
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/geocoder_stubs"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    post(sign_in_url, params: {email: user.email, password: "Secret1*3*5*"})
    user
  end
end

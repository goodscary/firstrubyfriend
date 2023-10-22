ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

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

  def create_user
    User.create!(
      email: "andy@goodscary.com",
      password: "Secret1*3*5*",
      city: "Brighton",
      country_code: "GB",
      lat: 50.827778,
      lng: -0.152778,
      demographic_year_started_ruby: 2023,
      demographic_year_started_programming: 2022,
      demographic_underrepresented_group: false,
      verified: true
    )
  end

  def create_mentor
    User.create!(
      email: "mentor@example.com",
      password: "Secret1*3*5*",
      verified: true
    )
  end

  def create_applicant
    User.create!(
      email: "applicant@example.com",
      password: "Secret1*3*5*",
      verified: true
    )
  end
end

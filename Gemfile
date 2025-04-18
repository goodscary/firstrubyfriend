source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 8"

gem "authentication-zero"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "bcrypt" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "country_select"
gem "geocoder"
# gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "kredis" # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem "propshaft" # The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "sqlite3" # Use SQLite3 as the database for Active Record [https://github.com/rails/rails/blob/v8.0.0/activerecord/README.md]
gem "puma" # Use the Puma web server [https://github.com/puma/puma]
gem "pwned" # Use Pwned to check if a password has been found in any of the huge data breaches [https://github.com/philnash/pwned]
gem "rails_icons"
gem "redis" # Use Redis adapter to run Action Cable in production
gem "sqlpkg"
gem "stimulus-rails" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "tailwindcss-rails" # Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "turbo-rails" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "omniauth-github"
# Provides a mitigation against CVE-2015-9284 [https://github.com/cookpad/omniauth-rails_csrf_protection]
gem "omniauth-rails_csrf_protection"
gem "ulid-rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]   # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "standard"
  gem "faker"
end

group :development do
  gem "rack-mini-profiler" # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "web-console" # Use console on exceptions pages [https://github.com/rails/web-console]
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  # gem "webdrivers" # removing this because it's causing issues with the CI -> https://github.com/titusfortner/webdrivers/issues/247#issuecomment-1641879165
end

gem "rack-ratelimit", group: :production # Use Rack::Ratelimit to rate limit requests [https://github.com/jeremy/rack-ratelimit]

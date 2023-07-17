source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

# Use specific branch of Rails
gem "rails", github: "rails/rails", branch: "7-0-stable"

gem "authentication-zero"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "bcrypt" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "omniauth" # Use OmniAuth to support multi-provider authentication [https://github.com/omniauth/omniauth]
gem "omniauth-github"
gem "omniauth-rails_csrf_protection" # Provides a mitigation against CVE-2015-9284 [https://github.com/cookpad/omniauth-rails_csrf_protection]
gem "propshaft" # The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "pg" # Use postgresql as the database for Active Record
gem "puma" # Use the Puma web server [https://github.com/puma/puma]
gem "redis" # Use Redis adapter to run Action Cable in production
gem "stimulus-rails" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "tailwindcss-rails" # Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "turbo-rails" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]   # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "standard"
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
  gem "webdrivers"
end

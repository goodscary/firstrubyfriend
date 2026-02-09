# Tech Stack

## Backend

| Component | Technology | Notes |
|-----------|------------|-------|
| Framework | Rails 8 | Latest Rails with modern defaults |
| Ruby | 3.4.4 | Specified in `.ruby-version` |
| Database | SQLite3 | Simple, file-based, sufficient for current scale |
| Background Jobs | Solid Queue | Rails 8 default, backed by SQLite |
| Caching/Realtime | Kredis + Redis | Higher-level Redis data structures |

## Frontend

| Component | Technology | Notes |
|-----------|------------|-------|
| CSS | Tailwind CSS | Utility-first, via tailwindcss-rails gem |
| JavaScript | Hotwire (Turbo + Stimulus) | Rails default for SPA-like interactions |
| Asset Pipeline | Propshaft + Importmaps | Modern Rails asset handling, no Node.js build step |
| Icons | rails_icons | Icon helper gem |

## Authentication

| Component | Technology | Notes |
|-----------|------------|-------|
| Auth Framework | Authentication Zero | Generates auth scaffolding |
| OAuth | omniauth-github | GitHub sign-in for developers |
| Password Security | bcrypt + pwned | Secure hashing + breached password checking |
| Admin Auth | HTTP Basic | Simple protection for `/admin/*` routes |

## External Services

| Service | Purpose | Notes |
|---------|---------|-------|
| Geocoder | Location/timezone matching | Converts city/country to lat/lng |
| Mailcoach | Email subscriptions | Newsletter integration |
| Postmark | Transactional email | SMTP delivery in production |
| GitHub OAuth | Social login | Via omniauth-github |

## Development & Testing

| Component | Technology | Notes |
|-----------|------------|-------|
| Linting | StandardRB | Ruby style enforcement |
| Test Framework | Minitest | Rails default |
| Test Fixtures | Oaken | Ruby-based seeds, not YAML fixtures |
| System Tests | Capybara + Selenium | Browser-based testing |
| HTTP Mocking | WebMock | Mock external API calls in tests |
| Coverage | SimpleCov | Test coverage reporting |
| Debugging | debug gem | Ruby's built-in debugger |

## Infrastructure

| Component | Technology | Notes |
|-----------|------------|-------|
| Web Server | Puma | Rails default, threaded |
| Rate Limiting | rack-ratelimit | Production request throttling |
| Credentials | Rails encrypted credentials | Separate files for dev/test and production |

## Key Gems

```ruby
# Core
rails ~> 8
sqlite3
puma
redis
kredis

# Auth
authentication-zero
bcrypt
pwned
omniauth-github
omniauth-rails_csrf_protection

# Frontend
tailwindcss-rails
turbo-rails
stimulus-rails
importmap-rails
propshaft

# Features
geocoder
country_select
prefixed_ids
active_job-performs

# Dev/Test
standard
debug
oaken
capybara
selenium-webdriver
webmock
simplecov
faker
```

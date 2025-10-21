# Tech Stack

## Backend Framework
- **Ruby 3.4.4** - Programming language
- **Rails 8.0** - Web application framework
- **Puma** - Web server

## Database & Data Storage
- **SQLite3** - Primary database (Active Record)
- **Redis** - Cache and Action Cable adapter
- **Kredis** - Higher-level Redis data types
- **sqlpkg** - SQLite package management

## Authentication & Security
- **Authentication Zero** - Authentication system generator
- **bcrypt** - Password hashing (has_secure_password)
- **OmniAuth GitHub** - GitHub OAuth integration
- **omniauth-rails_csrf_protection** - OAuth CSRF protection
- **pwned** - Password breach checking
- **rack-ratelimit** - API rate limiting (production)

## Frontend
- **Tailwind CSS** - Utility-first CSS framework (via tailwindcss-rails)
- **Propshaft** - Modern asset pipeline
- **Importmap Rails** - JavaScript module management with import maps
- **Stimulus Rails** - Modest JavaScript framework (Hotwire)
- **Turbo Rails** - SPA-like page acceleration (Hotwire)
- **rails_icons** - Icon system

## Geographic & Localization
- **Geocoder** - Geographic location and distance calculations
- **country_select** - Country selection form helpers

## Utilities & Helpers
- **prefixed_ids** - Friendly ID prefixes for models

## Development Tools
- **debug** - Ruby debugging
- **rails-mcp-server** - MCP server for Rails/Claude Code integration
- **Standard** - Ruby style guide and linter
- **Faker** - Test data generation
- **rack-mini-profiler** - Performance profiling with speed badges
- **web-console** - In-browser debugging console

## Testing
- **Minitest** - Test framework (Rails default)
- **Capybara** - System/integration testing
- **Selenium WebDriver** - Browser automation for system tests
- **SimpleCov** - Code coverage analysis

## Code Quality & Standards
- **Standard Ruby** - Ruby style guide, linter, and formatter (replaces RuboCop)
- Follows Rails 8 conventions and best practices
- Test-driven development with comprehensive test coverage

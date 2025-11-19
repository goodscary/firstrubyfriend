# First Ruby Friend

A community platform for Ruby developers to connect and help each other.

## Project Overview

- **Framework**: Rails 8
- **Ruby Version**: 3.4.4
- **Database**: SQLite3
- **CSS**: Tailwind CSS
- **JavaScript**: Hotwire (Turbo + Stimulus) with importmaps
- **Authentication**: Authentication Zero with GitHub OAuth

## Quick Start

```bash
bin/setup          # Install dependencies and prepare database
bin/dev            # Start development server (or `rails s`)
```

## Testing

```bash
rails test                    # Run all tests
rails test test/models        # Run model tests
rails test test/file.rb       # Run specific file
rails test test/file.rb:10    # Run specific test at line
```

- Tests use Oaken for seed data (not traditional YAML fixtures)
- System tests use Capybara with Selenium

## Key Dependencies

- **kredis** - Higher-level Redis data types
- **geocoder** - Location services
- **pwned** - Password breach checking
- **prefixed_ids** - Public-facing IDs
- **omniauth-github** - GitHub OAuth authentication

## Database

Uses SQLite3 for all environments. Database files stored in `storage/` directory.

## Architecture Notes

- Standard Rails MVC structure
- Authentication Zero provides the auth system - check gem capabilities before implementing auth features
- Avoid custom CSS - use Tailwind utility classes
- Uses Hotwire for interactivity (Turbo for navigation, Stimulus for JS)

## Development Notes

- **Debugging**: Use `binding.break` or `debugger` - requires `rails s` (not `bin/dev`)
- **Linting**: Uses StandardRB for code style

## Environment Variables

The project uses standard Rails environment variables. For cloud execution, ensure any required secrets are configured in GitHub repository settings.

# First Ruby Friend

A mentorship matching platform connecting early-career Ruby developers with experienced mentors.

First Ruby Friend uses an intelligent matching algorithm that considers geographic proximity (for timezone compatibility), spoken languages, and mentoring style preferences (career guidance vs. code review) to create productive mentor-mentee relationships.

## Features

- **Intelligent Matching** - Multi-factor scoring based on location, timezone, language, and mentoring preferences
- **Dual Mentoring Styles** - Supports both career mentorship and technical code mentorship
- **Geographic Awareness** - Prioritizes timezone-compatible matches while supporting remote mentorship
- **GitHub OAuth** - Sign in with GitHub alongside traditional email/password

## Setup

### Requirements

- Ruby 3.4.4
- Redis (for Kredis)
- SQLite3

### Installation

```bash
# Clone the repository
git clone https://github.com/goodscary/firstrubyfriend.git
cd firstrubyfriend

# Install dependencies and set up database
bin/setup

# Start the development server
bin/dev
```

### Environment Variables

For full functionality, configure these optional environment variables:

| Variable | Purpose |
|----------|---------|
| `GITHUB_CLIENT_ID` | GitHub OAuth app client ID |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth app secret |
| `GEOCODER_API_KEY` | Geocoding service API key |
| `MAILCOACH_*` | Mailcoach email integration |

## Development

### Running the Server

```bash
bin/dev      # Start with Procfile (CSS watching, etc.)
rails s      # Start Rails only (required for debugging)
```

### Running Tests

```bash
rails test                    # All tests
rails test test/models        # Model tests only
rails test test/file.rb       # Specific file
rails test test/file.rb:42    # Specific test at line
rails test:system             # System tests (requires Chrome)
```

### Code Style

This project uses [StandardRB](https://github.com/standardrb/standard) for Ruby code formatting:

```bash
bin/standardrb         # Check for issues
bin/standardrb --fix   # Auto-fix issues
```

### Debugging

We use the [`debug` gem](https://github.com/ruby/debug). Breakpoints require starting the server with `rails s` (not `bin/dev`):

```ruby
binding.break  # or `debugger` or `binding.b`
```

## Architecture

### Tech Stack

- **Framework**: Rails 8
- **Database**: SQLite3
- **CSS**: Tailwind CSS (avoid custom styles)
- **JavaScript**: Hotwire (Turbo + Stimulus) with importmaps
- **Authentication**: [Authentication Zero](https://github.com/lazaronixon/authentication-zero) with GitHub OAuth

### How Matching Works

The `MentorshipMatcher` calculates a score (0-100) for each potential mentor-applicant pair:

| Factor | Points | Description |
|--------|--------|-------------|
| Country | 40 | Same country match |
| Distance | 5-30 | 30 pts same timezone, 10 pts near (+/-2h), 5 pts distant |
| Preferences | 5-30 | 15 pts each for career/code match (local), 5 pts (remote) |

Matches require at least one shared spoken language.

### Key Models

- **User** - Both mentors and applicants; role determined by `available_as_mentor_at` or `requested_mentorship_at` timestamps
- **Mentorship** - Links mentor and applicant with status tracking (pending/active/ended/rejected)
- **MentorQuestionnaire / ApplicantQuestionnaire** - Detailed intake information

## Contributing

1. [Fork the repository](https://github.com/goodscary/firstrubyfriend/fork)
2. Clone your fork and `cd` into the project directory
3. Run `bin/setup` to install dependencies
4. Create a branch for your feature
5. Write tests for your changes
6. Ensure `rails test` and `bin/standardrb` pass
7. Push and open a pull request

## License

This project is open source under the [MIT License](LICENSE).

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

First Ruby Friend - A mentor matching platform connecting early-career Ruby developers with experienced mentors.

**Stack**: Rails 8, Ruby 3.4.4, SQLite3, Tailwind CSS, Hotwire (Turbo + Stimulus), importmaps

## Commands

```bash
bin/setup              # Install dependencies and prepare database
bin/dev                # Start dev server (or `rails s` for debugging)
rails test             # Run all tests
rails test test/models # Run model tests
rails test test/file.rb:10  # Run specific test at line
bin/standardrb         # Lint with StandardRB
bin/standardrb --fix   # Auto-fix lint issues
```

**Debugging**: Use `binding.break` or `debugger` - requires `rails s` (not `bin/dev`)

## Architecture

### Domain Model

- **User** - Central entity with roles determined by timestamps:
  - `available_as_mentor_at` present = mentor
  - `requested_mentorship_at` present = applicant
  - Uses `prefixed_ids` for public-facing IDs (e.g., `usr_xxx`)
  - Stores questionnaire responses in JSON `questionnaire_responses` column

- **Mentorship** - Links mentor and applicant users
  - States: `pending`, `active`, `ended`, `rejected`
  - Tracks monthly check-in email timestamps

- **MentorshipMatcher** - Scoring algorithm matching applicants to mentors based on:
  - Country match (40 pts)
  - Distance/timezone proximity (5-30 pts)
  - Career/code mentorship preference alignment (5-15 pts per match)
  - Shared language requirement

### Key Patterns

- **CsvImportable** concern - Shared CSV import logic for `User` and `Mentorship` models
- **Matchable** concern - User matching capabilities
- **Oaken** for test seeds - Ruby-based fixtures in `db/seeds/test/seeds.rb`
- **ApplicationClient** base class for external API clients (e.g., `MailcoachClient`)

### Authentication

Uses Authentication Zero gem with GitHub OAuth. Check gem capabilities before implementing auth features.

## Test Data

Tests use Oaken (not YAML fixtures). Reference seeds in tests like fixtures:
```ruby
users(:basic)      # db/seeds/test/seeds.rb
languages(:english)
```

Standard test password: `Secret1*3*5*`

## Style Guidelines

- Use Tailwind utility classes, avoid custom CSS
- Use Hotwire for interactivity (Turbo for navigation, Stimulus for JS)
- Follow StandardRB code style

# Agent OS - First Ruby Friend Mentorship Platform

## Overview
This is the Agent OS configuration for the First Ruby Friend mentorship platform - a Rails application that connects Ruby mentors with learners/applicants.

## Project Structure
- **Application Type**: Ruby on Rails web application
- **Purpose**: Mentorship matching platform for Ruby developers
- **Key Features**:
  - User authentication and registration
  - Mentor/Applicant questionnaires
  - Mentorship matching system
  - Email notifications for active mentorships
  - Geographic location-based matching

## Directory Structure
- `/instructions` - Task-specific instructions for agents
- `/prompts` - System prompts and templates
- `/hooks` - Git hooks and automation scripts
- `/tools` - Development tools and utilities
- `/docs` - Project documentation and guidelines

## Key Technologies
- Ruby on Rails
- SQLite database
- Tailwind CSS for styling
- Authentication Zero for auth system
- Geocoder for location services
- Stimulus.js for frontend interactions

## Development Commands
- `rails test` - Run test suite
- `rails s` or `bin/dev` - Start development server
- `bin/setup` - Initial setup script
- `rails test filename.rb` - Run specific test file
- `rails test filename.rb:line` - Run specific test

## Testing Strategy
- Minitest for unit and integration tests
- System tests for end-to-end testing
- Test fixtures for sample data
- Coverage analysis available

## Code Standards
- Follow Rails conventions
- Use Tailwind CSS utilities (avoid custom styles)
- Leverage Authentication Zero for auth features
- Write tests for new features
- Use debug gem for debugging (with `rails s`, not `bin/dev`)
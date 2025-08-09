# Claude Assistant Guide - First Ruby Friend

## Project Overview
You are working on First Ruby Friend, a Ruby on Rails mentorship platform that connects experienced Ruby developers (mentors) with learners (applicants).

## Key Commands to Run

### After making code changes:
```bash
rails test  # Always run tests after changes
```

### For debugging:
```bash
rails s  # Use this instead of bin/dev for debugging with binding.break
```

## Project Structure
- Rails MVC application
- SQLite database (development)
- Tailwind CSS for styling
- Minitest for testing
- Authentication Zero for auth

## Important Files
- `app/models/user.rb` - Core user model with mentor/applicant roles
- `app/models/mentorship.rb` - Manages mentor-applicant relationships
- `app/controllers/` - Request handlers
- `test/` - All test files
- `config/routes.rb` - URL routing

## Code Standards
1. **Always write tests first** (TDD)
2. **Follow Rails conventions** strictly
3. **Use Tailwind utilities** (no custom CSS)
4. **Keep controllers thin**, move logic to models/services
5. **Use strong parameters** for security
6. **Write descriptive test names**

## Common Patterns in This Codebase

### Authentication
- Uses `has_secure_password` in User model
- Session-based authentication
- Email verification tokens

### Database Relations
- User has many mentorship_roles_as_mentor
- User has many mentorship_roles_as_applicant
- Mentorship belongs to mentor and applicant

### Testing
- Use fixtures for test data
- Test files mirror app structure
- System tests for user workflows

## Before Committing
1. Run `rails test` - ensure all tests pass
2. Check for N+1 queries
3. Verify database migrations are reversible
4. Update documentation if needed

## Common Tasks

### Adding a new feature:
1. Create tests first
2. Write minimal code to pass tests
3. Refactor
4. Run full test suite
5. Update documentation

### Debugging:
1. Use `binding.break` in code
2. Start server with `rails s` (not bin/dev)
3. Check `log/development.log`
4. Use `rails console` for testing

### Database changes:
1. Generate migration: `rails g migration Name`
2. Run migration: `rails db:migrate`
3. Update model validations
4. Write tests for changes

## Key Business Logic
- **Mentorship Matching**: Based on questionnaire responses, location, and languages
- **Email Sequences**: Automated monthly emails to active mentorships
- **User Roles**: Users can be mentors, applicants, or both
- **Geographic Matching**: Uses geocoder gem for location-based matching

## Security Considerations
- Always validate user input
- Use strong parameters in controllers
- Check authorization before actions
- Never expose sensitive data in logs

## Performance Tips
- Use `includes()` to avoid N+1 queries
- Add database indexes for frequently queried columns
- Cache expensive computations
- Use background jobs for heavy tasks

## Agent OS Integration
The `.agent-os/` directory contains:
- `/instructions/` - Task-specific guides
- `/prompts/` - System prompts
- `/docs/` - Project documentation
- `/config.yml` - Project configuration

## Quick Fixes

### If tests fail:
1. Read error message carefully
2. Check test file for context
3. Verify fixtures are correct
4. Run single test to isolate issue

### If server won't start:
1. Check port 3000 availability
2. Run `bundle install`
3. Run `rails db:migrate`
4. Check log files

## Remember
- This is a community project to help Ruby learners
- Code quality matters - we're teaching by example
- Be mindful of user privacy and data security
- Tests are documentation - write them clearly
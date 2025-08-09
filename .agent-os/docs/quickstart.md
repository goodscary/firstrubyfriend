# Quick Start Guide for Developers

## Getting Started with First Ruby Friend Development

### Prerequisites
- Ruby 3.4+ installed
- Bundler 2.6.9+
- Node.js and Yarn (for JavaScript dependencies)
- Git

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/goodscary/firstrubyfriend.git
   cd firstrubyfriend
   ```

2. **Run setup script**
   ```bash
   bin/setup
   ```
   This will:
   - Install Ruby dependencies
   - Install JavaScript dependencies
   - Setup database
   - Run initial migrations
   - Seed sample data

3. **Start the development server**
   ```bash
   rails s
   # or for full dev environment with asset compilation:
   bin/dev
   ```

4. **Run tests**
   ```bash
   rails test
   ```

### Development Workflow

#### Creating a New Feature

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write tests first (TDD)**
   ```bash
   # Generate test file if needed
   rails generate test_unit:model YourModel
   ```

3. **Implement the feature**
   - Follow Rails conventions
   - Use existing patterns in the codebase
   - Keep controllers thin, models thick

4. **Run tests**
   ```bash
   rails test
   # Or specific test
   rails test test/models/your_model_test.rb
   ```

5. **Check code quality**
   ```bash
   # Run linter if configured
   # Check for N+1 queries
   # Review security implications
   ```

6. **Commit changes**
   ```bash
   git add .
   git commit -m "Add your feature description"
   ```

### Common Development Tasks

#### Database Operations

```bash
# Create a new migration
rails generate migration AddFieldToTable field:type

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Reset database
rails db:reset

# Seed database
rails db:seed
```

#### Model Generation

```bash
# Generate model with migration
rails generate model ModelName field1:type field2:type

# Generate controller
rails generate controller ControllerName action1 action2
```

#### Debugging

```ruby
# Add breakpoint in code
binding.break  # or debugger or binding.b

# Start server for debugging (not bin/dev)
rails s

# Use Rails console
rails c
```

#### Testing

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/user_test.rb

# Run specific test method
rails test test/models/user_test.rb:15

# Run with verbose output
rails test -v
```

### Key Project Files

- `Gemfile` - Ruby dependencies
- `package.json` - JavaScript dependencies
- `config/routes.rb` - Application routes
- `db/schema.rb` - Current database schema
- `config/database.yml` - Database configuration
- `.env` or `config/credentials.yml.enc` - Environment variables

### Project Structure

```
app/
├── controllers/     # Request handlers
├── models/         # Business logic and data
├── views/          # Templates
├── helpers/        # View helpers
├── mailers/        # Email handlers
├── javascript/     # Stimulus controllers
└── assets/         # CSS and images

test/
├── controllers/    # Controller tests
├── models/        # Model tests
├── system/        # End-to-end tests
├── fixtures/      # Test data
└── test_helper.rb # Test configuration
```

### Useful Rails Commands

```bash
# Rails console (interactive Ruby)
rails c

# Database console
rails db

# View routes
rails routes
rails routes | grep user  # Filter routes

# Clear cache
rails tmp:cache:clear

# View logs
tail -f log/development.log
```

### Environment Variables

Development environment variables can be set in:
- `config/credentials/development.yml.enc` (encrypted)
- `.env` file (if using dotenv gem)
- Direct environment export

Edit credentials:
```bash
rails credentials:edit --environment development
```

### Troubleshooting

#### Common Issues

1. **Database errors**
   ```bash
   rails db:reset  # Reset database
   rails db:migrate:status  # Check migration status
   ```

2. **Asset compilation issues**
   ```bash
   rails assets:precompile
   rails assets:clean
   ```

3. **Dependency issues**
   ```bash
   bundle install
   yarn install
   ```

4. **Server won't start**
   - Check if port 3000 is in use
   - Check log files for errors
   - Ensure all dependencies are installed

### Code Style Guidelines

- Use 2 spaces for indentation
- Follow Rails naming conventions
- Write descriptive commit messages
- Add tests for new features
- Document complex logic
- Use Rails helpers and methods

### Getting Help

- Check existing code for patterns
- Review Rails guides: https://guides.rubyonrails.org
- Run `rails --help` for command options
- Check test files for usage examples
- Review PRs for code style

### Next Steps

1. Familiarize yourself with the codebase
2. Run the test suite
3. Try creating a simple feature
4. Review the product plan
5. Check open issues for tasks

Welcome to First Ruby Friend development!
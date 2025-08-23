# Technical Stack - First Ruby Friend

> Last Updated: 2025-08-23
> Version: 1.0.0

## Application Framework

- **Framework:** Ruby on Rails 8
- **Version:** Latest stable Rails 8.x
- **Architecture:** MVC (Model-View-Controller)
- **API:** Traditional Rails application with HTML responses

## Database

- **Development Database:** SQLite
- **Production Database:** PostgreSQL (planned migration)
- **ORM:** Active Record
- **Migrations:** Rails migrations with reversibility focus

## Frontend Technologies

### CSS Framework
- **Framework:** Tailwind CSS with DaisyUI component library
- **Approach:** Utility-first CSS with no custom CSS files
- **Components:** DaisyUI pre-built components for consistent UI
- **Responsive Design:** Mobile-first approach with Tailwind breakpoints

### JavaScript Framework
- **Framework:** Hotwire (Turbo + Stimulus)
- **Turbo:** For SPA-like experience without JavaScript frameworks
- **Stimulus:** Lightweight JavaScript controllers for enhanced interactivity
- **Approach:** Progressive enhancement with minimal JavaScript

## Authentication and Security

- **Authentication:** Authentication Zero
- **Session Management:** Rails session-based authentication
- **Password Security:** bcrypt with has_secure_password
- **Password Validation:** Pwned gem for compromised password checking
- **Authorization:** Role-based access control (mentor/applicant/admin)

## Background Job Processing

- **Current:** Basic Rails job infrastructure
- **Planned:** Solid Queue for Rails 8 job processing
- **Queue Management:** Solid Queue recurring jobs (to be implemented)
- **Job Monitoring:** Built-in Rails job monitoring

## Testing Framework

- **Primary Framework:** Minitest
- **Test Types:** Unit tests, integration tests, system tests
- **Coverage:** SimpleCov for test coverage reporting
- **Approach:** Test-driven development (TDD)
- **Fixtures:** Rails fixtures for test data management

## Code Quality and Standards

- **Linting:** Standard gem for Ruby style enforcement
- **Code Coverage:** SimpleCov integration
- **Documentation:** Inline documentation with YARD conventions
- **Standards:** Rails conventions with strict adherence

## Geographic and Mapping

- **Geocoding:** Geocoder gem for address-to-coordinate conversion
- **Location Matching:** Geographic proximity calculations
- **Time Zone:** Rails time zone handling for scheduling
- **Address Validation:** Geocoder validation for user locations

## Unique Identifiers

- **Primary Keys:** ULID (Universally Unique Lexicographically Sortable Identifier)
- **Benefits:** Better distributed system support than UUIDs
- **Sortability:** Chronological ordering built into identifiers
- **URL Safety:** Base32 encoding for clean URLs

## Development Tools

### Database Administration
- **Development:** SQLite browser/command line tools
- **Production:** PostgreSQL admin tools (planned)
- **Migrations:** Rails migration system with rollback support

### Performance Monitoring
- **Development:** Rails built-in tools and logging
- **Production:** Application performance monitoring (to be determined)
- **Database:** Query analysis and N+1 detection

## Deployment and Infrastructure

- **Current:** Development environment setup
- **Planned Production:** Cloud hosting with PostgreSQL
- **CI/CD:** GitHub Actions (to be configured)
- **Monitoring:** Application and error monitoring (to be determined)

## Third-Party Integrations

### Email Services
- **Development:** Rails ActionMailer with local delivery
- **Production:** Email service provider (to be determined)
- **Templates:** Rails ActionMailer with HTML/text templates

### External APIs
- **Geocoding:** Google Maps API or equivalent via Geocoder
- **Security:** Pwned Passwords API for password validation
- **Future:** Potential job board or career platform integrations

## Security Considerations

- **Input Validation:** Strong parameters and model validations
- **SQL Injection:** Active Record ORM protection
- **Cross-Site Scripting:** Rails built-in XSS protection
- **CSRF Protection:** Rails CSRF tokens
- **Password Security:** bcrypt hashing with Pwned validation

## Performance Optimizations

- **Database Queries:** includes() for N+1 query prevention
- **Caching:** Rails fragment and page caching (as needed)
- **Asset Pipeline:** Rails asset pipeline with compression
- **Background Jobs:** Solid Queue for heavy computations

## Development Environment

- **Ruby Version:** Latest stable Ruby 3.x
- **Package Management:** Bundler for gem management
- **Database Setup:** SQLite for local development
- **Server:** Puma web server
- **Hot Reloading:** Rails live reloading in development

## Future Technical Considerations

### Potential Additions
- **Mobile API:** RESTful API for mobile application
- **Real-time Features:** ActionCable for WebSocket connections
- **Advanced Analytics:** Business intelligence tools integration
- **Microservices:** Service extraction as platform grows
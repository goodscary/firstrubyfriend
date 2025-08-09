# Product Analysis Instructions

## Purpose
Perform comprehensive analysis of the First Ruby Friend codebase to identify strengths, weaknesses, and opportunities for improvement.

## Analysis Framework

### 1. Architecture Review
- **Database Schema**: Analyze tables, relationships, indexes
- **Application Structure**: MVC patterns, service objects, concerns
- **Dependencies**: Gem analysis, version management
- **Configuration**: Environment setup, credentials management

### 2. Code Quality Assessment
- **Test Coverage**: Current state, missing tests, test quality
- **Code Patterns**: Consistency, best practices, anti-patterns
- **Performance**: Query optimization, caching, N+1 issues
- **Security**: Vulnerabilities, authentication, authorization

### 3. Feature Analysis
- **Implemented Features**: Current functionality assessment
- **Missing Features**: Gap analysis with product vision
- **User Experience**: UI/UX evaluation, accessibility
- **Integration Points**: Third-party services, APIs

### 4. Technical Debt Evaluation
- **High Priority**: Security, data integrity, performance
- **Medium Priority**: Code organization, testing, documentation
- **Low Priority**: Nice-to-haves, optimizations

### 5. Scalability Assessment
- **Database**: Migration needs, indexing, partitioning
- **Application**: Caching strategy, background jobs, API design
- **Infrastructure**: Deployment, monitoring, logging

## Analysis Process

### Step 1: Codebase Scan
```bash
# Check project stats
find app -name "*.rb" | wc -l  # Ruby files count
rails stats                     # Rails statistics

# Dependency audit
bundle audit                    # Security vulnerabilities
bundle outdated                 # Outdated gems
```

### Step 2: Database Analysis
```ruby
# In Rails console
# Check table sizes
ActiveRecord::Base.connection.tables.map { |t| 
  [t, ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{t}").first] 
}

# Check indexes
ActiveRecord::Base.connection.indexes(:users)

# Find missing indexes
# Look for foreign keys without indexes
```

### Step 3: Test Coverage
```bash
# Run tests with coverage
COVERAGE=true rails test

# Check coverage report
open coverage/index.html

# Identify untested files
grep -r "class\|module" app/ | grep -v test
```

### Step 4: Performance Check
```ruby
# Check for N+1 queries
# Use bullet gem or manual review

# Find slow queries
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Memory usage
`ps aux | grep rails`
```

### Step 5: Security Audit
```bash
# Check for vulnerabilities
bundle audit check
brakeman

# Review authentication
grep -r "authenticate" app/
grep -r "authorize" app/
```

## Key Areas to Analyze

### Models
- Validations completeness
- Association efficiency
- Callback usage
- Scope definitions
- Business logic placement

### Controllers
- Action complexity
- Parameter handling
- Error management
- Response formats
- Before/after actions

### Views
- Template organization
- Partial usage
- Helper methods
- JavaScript integration
- Responsive design

### Routes
- RESTful compliance
- Namespace organization
- Constraint usage
- API versioning
- URL optimization

### Tests
- Coverage percentage
- Test types (unit, integration, system)
- Factory/fixture usage
- Test speed
- Edge case coverage

## Deliverables

### 1. Analysis Report
Create comprehensive document covering:
- Executive summary
- Current state assessment
- Technical debt inventory
- Performance bottlenecks
- Security vulnerabilities
- Scalability concerns

### 2. Recommendations
Prioritized list of:
- Critical fixes
- Quick wins
- Long-term improvements
- Architecture changes
- Tool additions

### 3. Implementation Roadmap
Sprint-based plan with:
- Task breakdown
- Time estimates
- Dependencies
- Success criteria
- Risk mitigation

### 4. Metrics Dashboard
Key indicators:
- Code quality scores
- Test coverage trends
- Performance metrics
- Security scan results
- Technical debt ratio

## Analysis Tools

### Static Analysis
- **RuboCop**: Style and complexity
- **Reek**: Code smells
- **Flog**: Complexity scoring
- **Flay**: Duplication detection

### Security
- **Brakeman**: Security scanner
- **Bundler Audit**: Dependency vulnerabilities
- **Rails Best Practices**: Security patterns

### Performance
- **Bullet**: N+1 query detection
- **Rack Mini Profiler**: Runtime analysis
- **Memory Profiler**: Memory usage
- **Benchmark**: Performance testing

### Testing
- **SimpleCov**: Coverage reporting
- **Parallel Tests**: Test performance
- **Guard**: Automated testing
- **Factory Bot**: Test data

## Report Template

```markdown
# Product Analysis - [Date]

## Overview
- Application: First Ruby Friend
- Version: [Current Version]
- Analysis Date: [Date]
- Analyzer: [Name/Team]

## Summary
[High-level findings]

## Detailed Findings

### Architecture
[Architectural assessment]

### Code Quality
[Quality metrics and issues]

### Performance
[Performance analysis]

### Security
[Security evaluation]

### Testing
[Test coverage and quality]

## Recommendations

### Immediate (Week 1)
1. [Critical issue 1]
2. [Critical issue 2]

### Short-term (Month 1)
1. [Important improvement 1]
2. [Important improvement 2]

### Long-term (Quarter 1)
1. [Strategic change 1]
2. [Strategic change 2]

## Metrics
- Current test coverage: X%
- Code complexity: X
- Security issues: X
- Performance score: X/100

## Conclusion
[Summary and next steps]
```

## Best Practices

### Do's
- Be objective and data-driven
- Prioritize by impact
- Consider effort vs. benefit
- Document assumptions
- Provide actionable recommendations

### Don'ts
- Don't criticize without solutions
- Don't ignore positive aspects
- Don't overwhelm with details
- Don't skip security review
- Don't forget user perspective

## Follow-up Actions

1. **Review with team**: Present findings
2. **Create tickets**: Break down into tasks
3. **Update documentation**: Reflect changes
4. **Monitor progress**: Track improvements
5. **Re-analyze**: Quarterly assessment

## Success Criteria

Analysis is complete when:
- [ ] All code reviewed
- [ ] Tests analyzed
- [ ] Performance measured
- [ ] Security scanned
- [ ] Report generated
- [ ] Recommendations prioritized
- [ ] Roadmap created
- [ ] Team briefed
# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-25-historical-match-import/spec.md

> Created: 2025-08-25
> Version: 1.0.0

## Technical Requirements

### CSV File Processing
- **Parser**: Ruby standard library CSV with UTF-8 encoding
- **File Types**: Three distinct CSV formats (mentors, applicants, matches)
- **Validation**: Header validation, row completeness checks, data type validation
- **Error Handling**: Per-row error collection without stopping batch processing, output failures to STDOUT
- **Memory Management**: Streaming processing for large files (not loading entire file into memory)

### User Import System
- **Password Bypass**: Users created without password requirements using `password: nil`
- **Import Flagging**: `imported: true` boolean field to distinguish imported users
- **Email Verification**: Skip email confirmation for imported users
- **Duplicate Detection**: Email-based duplicate prevention with update-if-exists logic

### Data Mapping Layer
- **Flexible Headers**: Map various CSV header formats to existing Rails model attributes
- **Type Coercion**: String to appropriate data type conversion (dates, booleans, integers)
- **Default Values**: Apply sensible defaults for missing optional fields
- **Validation**: Use existing Rails model validations during import
- **Sanitization**: Clean and normalize text data (trim whitespace, standardize formats)

### Match Management System
- **Match Reassignment**: Void previous matches when participants get new matches
- **State Tracking**: Track match status changes (active → voided → reassigned)
- **Data Integrity**: Ensure referential integrity between users and matches
- **Relationship Validation**: Verify mentor/applicant role assignments are valid

### Email Date Backfilling
- **Theoretical Calculation**: Calculate when monthly emails would have been sent
- **12-Column Integration**: Map to existing email tracking columns (month_1_email_sent_at through month_12_email_sent_at)
- **Date Logic**: Base calculations on match creation date + monthly intervals
- **Realistic Timing**: Account for business days and avoid weekends/holidays
- **Cutoff Logic**: Don't backfill future dates or beyond 12-month period

### Batch Processing Architecture
- **Service Objects**: Use a Rails concern pattern for import operations, via a manually called rake task for each file
- **Transaction Management**: Wrap imports in database transactions with rollback capability
- **Progress Tracking**: Report processing progress for large batches
- **Error Aggregation**: Collect all errors before reporting (don't fail fast)
- **Memory Efficiency**: Process in configurable chunks (default: 100 records per batch)

## Approach

### Service Object Structure
```ruby
class User
  include HistoricalMentorImporter
  include HistoricalApplicantImporter
end

class Mentorship
  include HistoricalMatchImporter
end
```

### Processing Flow
1. **Pre-validation**: Verify file format and required headers
2. **User Import**: Create/update mentors and applicants first
3. **Match Import**: Process matches with user lookups
4. **Email Backfill**: Calculate and populate theoretical email send dates
5. **Validation Report**: Generate comprehensive success/error summary

### Error Handling Strategy
- **Granular Errors**: Track errors at file, row, and field levels
- **Continuation Logic**: Continue processing after non-fatal errors
- **Rollback Triggers**: Define fatal errors that require full rollback
- **Error Reporting**: Structured error messages with context and suggestions

### Data Validation Layers
1. **File Level**: Headers present, file readable, encoding valid
2. **Row Level**: Required fields present, data types correct
3. **Business Logic**: Email uniqueness, role validity, relationship constraints
4. **Database Level**: Rails model validations and database constraints

### Integration Points
- **User Model**: Extend with `imported` boolean field
- **Mentorship Model**: Use existing relationship and email tracking fields  
- **Authentication**: Bypass password requirements for imported users
- **Validation**: Leverage existing Rails validations and add import-specific checks

## External Dependencies

### Ruby Standard Library
- **CSV**: File parsing and processing
- **Date/Time**: Date calculations for email backfilling
- **Logger**: Structured logging for debugging and monitoring

### Rails Framework Components
- **ActiveRecord**: ORM for database operations and transactions
- **ActiveModel**: Validation and type conversion
- **ApplicationService**: Service object base class (if not present, create)

### No Additional Gems Required
- Utilize existing Rails and Ruby capabilities only
- No external parsing libraries or background job systems
- Maintain minimal dependency footprint

### Database Requirements
- **Migration**: Add `imported_at` timestamp (effectively boolean via `!!`) field to users table
- **Indexes**: Consider indexes on email for performance
- **Constraints**: Maintain existing database constraints and foreign keys, query if there's a constraint that conflicts with the importer
- **Rollback**: Ensure all changes are reversible via Rails migration rollbacks
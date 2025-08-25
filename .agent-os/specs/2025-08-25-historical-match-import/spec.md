# Spec Requirements Document

> Spec: Historical Match Import
> Created: 2025-08-25
> Status: Planning

## Overview

The First Ruby Friend platform needs to import historical data from the previous mentorship platform to maintain continuity for existing mentors and applicants. This involves importing CSV files containing mentor data, applicant data, and monthly match records from 2023 to present (approximately 2,000 records total).

The import system must create user accounts without passwords for historical users, establish mentorship relationships based on match data, handle match reassignments by voiding previous matches, and backfill theoretical email sent dates based on match creation dates.

## User Stories

**As a platform administrator, I want to:**
- Import mentor CSV files with 13 fields including contact details, work information, and preferences
- Import applicant CSV files with 15 fields including personal background, location, and learning goals
- Migrate the passed mentor & applicant data to questionnaire response answers where appropriate.
- Import monthly match CSV files linking applicants to mentors by email addresses
- Automatically create User records for mentors and applicants without requiring passwords
- Establish Mentorship records based on the imported match data
- Handle match reassignments by voiding previous matches when new ones are created for the same applicant
- Backfill email sent dates based on match creation dates to maintain email sequence integrity
- Receive comprehensive error reports for any import failures or validation issues
- Validate data integrity across all imported records

**As an existing mentor or applicant, I want to:**
- Have my historical profile data preserved in the new system
- See my previous mentorship matches reflected accurately
- Maintain continuity with my mentorship history and relationships

## Spec Scope

### Data Import Components
- **Mentor CSV Import**: 13 fields including Date, name, email, work details, location, preferences
- **Applicant CSV Import**: 15 fields including Date, name, email, location, background info, learning goals
- **Monthly Match CSV Import**: 4 fields linking applicant email, country, city, mentor email
- **User Account Creation**: Generate User records without passwords for all imported contacts
- **Mentorship Relationship Creation**: Establish mentorship records based on match data
- **Match Reassignment Handling**: Void previous matches when new matches are created for same applicant
- **Email Date Backfilling**: Calculate theoretical email sent dates based on match creation dates

### Data Validation & Error Handling
- Comprehensive validation of all CSV fields
- Duplicate detection and handling across all import types
- Email format validation and uniqueness checking
- Geographic data validation for location fields
- Detailed error reporting with line numbers and specific validation failures
- Rollback capabilities for failed imports

### Data Integrity Features
- Cross-referencing between mentor/applicant emails and match records
- Orphaned match detection (matches without corresponding mentor/applicant records)
- Data consistency checks across all imported datasets
- Audit trail of import operations and modifications

## Out of Scope

- User password generation or email-based account activation flows
- Automatic email notifications to imported users about their new accounts
- Import of any additional data beyond the specified CSV formats
- Migration of file attachments or non-structured data from the previous platform
- Real-time sync capabilities with external systems
- Import scheduling or automation features
- Data export capabilities from the new system

## Expected Deliverable

A comprehensive import system that can:

1. **Process CSV Files**: Import mentor, applicant, and monthly match CSV files with full field validation
2. **Create User Accounts**: Generate User records for all imported contacts without password requirements
3. **Establish Relationships**: Create accurate Mentorship records based on match data
4. **Handle Reassignments**: Properly void and reassign matches when applicants are matched with new mentors
5. **Backfill Email Dates**: Calculate and populate email sent dates based on match creation timing
6. **Provide Error Reporting**: Generate detailed reports of import successes, failures, and data issues
7. **Maintain Data Integrity**: Ensure all imported data meets system validation requirements and business rules

The system should handle approximately 2,000 historical records from 2023-present while maintaining data consistency and providing clear visibility into the import process results.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-08-25-historical-match-import/tasks.md
- Technical Specification: @.agent-os/specs/2025-08-25-historical-match-import/sub-specs/technical-spec.md
- Database Schema: @.agent-os/specs/2025-08-25-historical-match-import/sub-specs/database-schema.md
- Tests Specification: @.agent-os/specs/2025-08-25-historical-match-import/sub-specs/tests.md
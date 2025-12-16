# Refactor: Inline Service Classes into Models

## Overview

Remove the `app/services/` directory and inline CSV import functionality into the appropriate models, following DHH/37signals Rails conventions of "fat models" organized with concerns.

## Current State

**5 service classes** in `app/services/`:

| Service | Purpose | Target Model |
|---------|---------|--------------|
| `CsvImportService` | Base class with CSV parsing infrastructure | Shared concern |
| `ApplicantImporter` | Import mentees from CSV (17 columns) | `User` |
| `MentorImporter` | Import mentors from CSV (15 columns) | `User` |
| `MatchImporter` | Create mentorship pairings | `Mentorship` |
| `EmailDateBackfiller` | Backfill email timestamps | `Mentorship` |

**Usage pattern**: Services are called from `ImportJob` and rake tasks only (no controller usage).

## Proposed Solution

### Architectural Pattern: Model Class Methods + Shared Concern

```ruby
# Shared CSV parsing infrastructure
# app/models/concerns/csv_importable.rb
module CsvImportable
  extend ActiveSupport::Concern
  # Template method pattern for CSV imports
end

# User model with import class methods
# app/models/user.rb
class User < ApplicationRecord
  include CsvImportable

  def self.import_applicants_from_csv(csv_content, use_transaction: false)
    # Inline ApplicantImporter logic
  end

  def self.import_mentors_from_csv(csv_content, use_transaction: false)
    # Inline MentorImporter logic
  end
end

# Mentorship model with import class methods
# app/models/mentorship.rb
class Mentorship < ApplicationRecord
  include CsvImportable

  def self.import_matches_from_csv(csv_content, use_transaction: false)
    # Inline MatchImporter logic
  end

  def self.backfill_email_dates(audit: false)
    # Inline EmailDateBackfiller logic
  end
end
```

### ImportJob Changes

```ruby
# app/jobs/import_job.rb
def perform(import_type, csv_content, report_id: nil)
  result = case import_type
  when "mentor"    then User.import_mentors_from_csv(csv_content)
  when "applicant" then User.import_applicants_from_csv(csv_content)
  when "match"     then Mentorship.import_matches_from_csv(csv_content)
  end
  # ...
end
```

## Technical Considerations

### Keep As-Is
- `ImportResult` class in `app/models/` (shared result object)
- `ImportReport` model (unchanged)
- Rake tasks (just call ImportJob as before)
- Transaction support via `use_transaction` parameter

### Changes Required
- Extract `CsvImportService` template method into `CsvImportable` concern
- Move importer logic into model class methods
- Update all tests to call model methods instead of service classes
- Update ImportJob to call model methods

### Data Model Issues Identified (Out of Scope)
The analysis revealed some data model inconsistencies that exist independently of this refactoring:
- Duplicate storage in structured columns AND `questionnaire_responses` JSON
- `applicant_questionnaires`/`mentor_questionnaires` tables exist but importers use JSON blob
- Geocoding triggers on every location update during import

These should be addressed separately to keep this refactoring focused.

## Acceptance Criteria

- [ ] Create `CsvImportable` concern with shared CSV parsing logic
- [ ] Add `User.import_applicants_from_csv` class method
- [ ] Add `User.import_mentors_from_csv` class method
- [ ] Add `Mentorship.import_matches_from_csv` class method
- [ ] Add `Mentorship.backfill_email_dates` class method
- [ ] Update `ImportJob` to call model methods
- [ ] Migrate all service tests to model tests
- [ ] Remove `app/services/` directory
- [ ] Verify rake tasks still work

## Implementation Plan

### Phase 1: Create Shared Concern
1. Create `app/models/concerns/csv_importable.rb`
2. Extract template method pattern from `CsvImportService`
3. Include error handling and result tracking

### Phase 2: Migrate User Imports
1. Add `import_applicants_from_csv` to User model
2. Migrate `ApplicantImporterTest` to `UserTest`
3. Add `import_mentors_from_csv` to User model
4. Migrate `MentorImporterTest` to `UserTest`

### Phase 3: Migrate Mentorship Imports
1. Add `import_matches_from_csv` to Mentorship model
2. Add `backfill_email_dates` to Mentorship model
3. Migrate tests

### Phase 4: Update Callers & Cleanup
1. Update `ImportJob` to use model methods
2. Verify rake tasks work
3. Remove `app/services/` directory
4. Remove `CsvImportService` base class

## Files to Modify

### New Files
- `app/models/concerns/csv_importable.rb`

### Modified Files
- `app/models/user.rb` - Add import class methods
- `app/models/mentorship.rb` - Add import and backfill class methods
- `app/jobs/import_job.rb` - Call model methods instead of services
- `test/models/user_test.rb` - Add import tests
- `test/models/mentorship_test.rb` - Add import tests

### Deleted Files
- `app/services/csv_import_service.rb`
- `app/services/applicant_importer.rb`
- `app/services/mentor_importer.rb`
- `app/services/match_importer.rb`
- `app/services/email_date_backfiller.rb`
- `test/services/applicant_importer_test.rb`
- `test/services/mentor_importer_test.rb`
- `test/services/match_importer_test.rb`
- `test/services/email_date_backfiller_test.rb`
- `test/services/csv_import_service_test.rb`

## References

### Internal
- `app/services/csv_import_service.rb:9-67` - Template method pattern to extract
- `app/jobs/import_job.rb:17-26` - Caller that needs updating
- `lib/tasks/imports.rake` - Rake tasks (unchanged, call ImportJob)

### External
- [37signals: Vanilla Rails is plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
- [37signals: Good concerns](https://dev.37signals.com/good-concerns/)
- [Put chubby models on a diet with concerns](https://signalvnoise.com/posts/3372-put-chubby-models-on-a-diet-with-concerns)

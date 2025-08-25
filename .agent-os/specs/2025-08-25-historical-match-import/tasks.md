# Spec Tasks

## Tasks

- [ ] 1. Create CSV Import Service Infrastructure
  - [ ] 1.1 Write tests for CSVImportService base class
  - [ ] 1.2 Implement CSVImportService with error handling and validation
  - [ ] 1.3 Create ImportResult class for tracking import outcomes
  - [ ] 1.4 Add CSV file format validation and parsing utilities
  - [ ] 1.5 Implement transaction-based rollback capabilities
  - [ ] 1.6 Verify all tests pass

- [ ] 2. Implement Mentor and Applicant CSV Import
  - [ ] 2.1 Write tests for MentorImporter service
  - [ ] 2.2 Create MentorImporter with field mapping for 13 CSV fields
  - [ ] 2.3 Write tests for ApplicantImporter service
  - [ ] 2.4 Create ApplicantImporter with field mapping for 15 CSV fields
  - [ ] 2.5 Implement User creation without passwords for imported records
  - [ ] 2.6 Add questionnaire response migration logic
  - [ ] 2.7 Handle duplicate email detection and merging
  - [ ] 2.8 Verify all tests pass

- [ ] 3. Build Monthly Match Import System
  - [ ] 3.1 Write tests for MatchImporter service
  - [ ] 3.2 Create MatchImporter with mentor/applicant lookup by email
  - [ ] 3.3 Implement Mentorship creation from match data
  - [ ] 3.4 Add match reassignment handling with voiding logic
  - [ ] 3.5 Create orphaned match detection and reporting
  - [ ] 3.6 Verify all tests pass

- [ ] 4. Implement Email Date Backfilling
  - [ ] 4.1 Write tests for EmailDateBackfiller service
  - [ ] 4.2 Calculate theoretical email sent dates based on match creation
  - [ ] 4.3 Update mentorship records with backfilled email dates
  - [ ] 4.4 Add audit trail for backfilled dates
  - [ ] 4.5 Verify all tests pass

- [ ] 5. Create Import Management Interface
  - [ ] 5.1 Write tests for ImportJob background job
  - [ ] 5.2 Implement ImportJob for async processing
  - [ ] 5.3 Create ImportReport model and generation logic
  - [ ] 5.4 Build comprehensive error reporting with line numbers
  - [ ] 5.5 Add data integrity validation across all imports
  - [ ] 5.6 Create rake tasks for manual import execution
  - [ ] 5.7 Verify all tests pass and integration works end-to-end
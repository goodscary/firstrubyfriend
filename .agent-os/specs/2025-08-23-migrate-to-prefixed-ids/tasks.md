# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-08-23-migrate-to-prefixed-ids/spec.md

> Created: 2025-08-23
> Status: Ready for Implementation

## Tasks

### 1. Setup Prefixed IDs Gem and Base Infrastructure ✅

1.1. ✅ Write tests for prefixed ID functionality on existing models
1.2. ✅ Add prefixed_ids gem to Gemfile and bundle install
1.3. ✅ Configure prefixed_ids gem with model prefixes (usr_, mnt_, ses_, mqr_, aqr_, evt_, prt_)
1.4. ✅ Update model files to include prefixed_ids configuration
1.5. ✅ Create test helpers for working with prefixed IDs in test suite
1.6. ✅ Update fixtures to work with integer IDs instead of ULIDs
1.7. ✅ Verify all model tests pass with prefixed ID configuration

### 2. Database Schema Migration - Core Models

2.1. Write tests for database migration with data preservation
2.2. Create migration to add integer primary key columns alongside existing ULID columns
2.3. Create migration to update User model foreign keys (mentorship relationships)
2.4. Create migration to update Mentorship model foreign keys  
2.5. Create migration to update Session model foreign keys
2.6. Test migrations in development environment with sample data
2.7. Create rollback procedures for each migration step
2.8. Verify all database tests pass after core model migrations

### 3. Database Schema Migration - Questionnaire and Token Models

3.1. Write tests for questionnaire and token model migrations
3.2. Create migration to update MentorQuestionnaire foreign keys to integer
3.3. Create migration to update ApplicantQuestionnaire foreign keys to integer
3.4. Create migration to update EmailVerificationToken foreign keys to integer
3.5. Create migration to update PasswordResetToken foreign keys to integer
3.6. Create migration to update Event model foreign keys to integer
3.7. Test all foreign key relationships work correctly with integer IDs
3.8. Verify all questionnaire and token model tests pass

### 4. Data Migration and ULID Cleanup

4.1. Write tests for data migration process with relationship preservation
4.2. Create data migration script to populate integer IDs while preserving relationships
4.3. Create verification script to ensure all relationships are maintained
4.4. Run data migration on development database and verify integrity
4.5. Create migration to drop old ULID columns after successful migration
4.6. Update historical import scripts to work with integer IDs
4.7. Test complete migration process from start to finish
4.8. Verify all integration tests pass with new ID structure

### 5. Application Layer Updates and Testing

5.1. Update controllers to handle prefixed IDs in routes and params
5.2. Update view templates to use prefixed IDs for public-facing identifiers
5.3. Update URL generation to use prefixed IDs instead of ULIDs
5.4. Run full test suite including system tests
5.5. Verify all tests pass and application functions correctly with prefixed IDs

**Note:** No real production data exists in this system yet, simplifying the migration process.
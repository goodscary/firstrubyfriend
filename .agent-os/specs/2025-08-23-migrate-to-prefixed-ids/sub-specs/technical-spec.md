# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-08-23-migrate-to-prefixed-ids/spec.md

## Technical Requirements

### Migration Strategy
- Create new integer ID columns alongside existing ULID columns
- Populate integer IDs with sequential values
- Update all foreign keys to reference new integer IDs  
- Remove ULID columns after verification
- Implement reversible migrations for rollback capability

### Prefixed IDs Configuration
- Configure unique prefix for each model (e.g., `usr_`, `mnt_`, `ses_`)
- Ensure prefixed IDs work in routes and controllers
- Update `to_param` methods for URL generation
- Implement `find_by_prefixed_id` for lookups

### Model Updates Required
- User model: prefix `usr_`
- Mentorship model: prefix `mnt_`
- Session model: prefix `ses_`
- MentorQuestionnaire: prefix `mqr_`
- ApplicantQuestionnaire: prefix `aqr_`
- Event model: prefix `evt_`
- EmailVerificationToken: prefix `evt_`
- PasswordResetToken: prefix `prt_`

### Controller Updates
- Update all `find` calls to use `find_by_prefixed_id`
- Ensure params permit prefixed IDs
- Update strong parameters if needed

### Testing Requirements
- Comprehensive test coverage for ID migrations
- Verify all relationships maintain integrity
- Test prefixed ID generation and lookup
- Ensure backward compatibility during migration

## External Dependencies

- **prefixed_ids** - Generate secure public IDs with model-specific prefixes
- **Justification:** Provides secure, non-enumerable public identifiers while maintaining simple integer primary keys internally
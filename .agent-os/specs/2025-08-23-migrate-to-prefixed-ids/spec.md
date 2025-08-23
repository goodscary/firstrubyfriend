# Spec Requirements Document

> Spec: Migrate from ULID to Integer IDs with Prefixed IDs
> Created: 2025-08-23

## Overview

Replace ULID primary keys with standard integer IDs and implement the prefixed_ids gem for public-facing identifiers. This migration will simplify database operations while maintaining secure, non-sequential public IDs for better security and user experience.

## User Stories

### Admin Database Migration

As a system administrator, I want to migrate existing ULID records to integer IDs, so that the database uses standard Rails conventions and improves query performance.

The migration will convert all existing ULID primary and foreign keys to integers, ensuring data integrity is maintained throughout the process. A rollback strategy will be implemented to revert changes if issues arise.

### Developer Experience

As a developer, I want to use prefixed IDs in URLs and APIs, so that IDs are both readable and secure without exposing sequential database IDs.

Public-facing IDs will use prefixes like `usr_` for users, `mnt_` for mentorships, making them easily identifiable while preventing enumeration attacks.

## Spec Scope

1. **Database Migration** - Convert all ULID columns to integer primary keys with auto-increment
2. **Prefixed IDs Integration** - Add prefixed_ids gem and configure prefixes for all models
3. **Foreign Key Updates** - Update all foreign key references from ULID to integer
4. **Data Migration** - Safely migrate existing records preserving all relationships
5. **Historical Import Support** - Update import process to work with new ID structure

## Out of Scope

- Changing the authentication system
- Modifying business logic unrelated to IDs
- UI/UX changes beyond ID display updates
- Performance optimizations beyond ID-related queries

## Expected Deliverable

1. All models using integer IDs with working prefixed public identifiers
2. Successfully migrated database with zero data loss
3. Historical import functionality compatible with new ID structure
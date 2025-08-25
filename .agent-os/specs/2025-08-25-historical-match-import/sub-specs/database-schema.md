# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-08-25-historical-match-import/spec.md

> Created: 2025-08-25
> Version: 1.0.0

## Schema Changes

### Users Table Modifications

**New Columns:**
```ruby
add_column :users, :imported_at, :timestamp, null: true
```

**Purpose:**
- `imported_at`: Distinguishes imported users from naturally registered users
- Additional questionnaire fields: Support CSV data that doesn't map to existing User model fields

**Indexes:**
```ruby
add_index :users, :imported_at
add_index :users, :email # Enhance existing for CSV matching performance
```

### Mentorships Table Modifications

**New Columns:**
```ruby
add_column :mentorships, :ended_reason, :integer, null: true
add_column :mentorships, :ended_at, :timestamp, null: true
```

**Enum Definition:**
Use string-based enums

```ruby
enum ended_reason: [
  :mutual_agreement,
  :applicant_inactivity,
  :mentor_inactivity,
  :completed
].(&:itself)
```

**Purpose:**
- `ended_reason`: Tracks why matches ended (required for historical data integrity)
- `ended_at`: Audit trail timestamp for voided matches


## Migrations

### Migration 1: Add Import Tracking to Users
```ruby
class AddImportTrackingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :imported_at, :timestamp, null: true
    
    add_index :users, :imported_at
  end
end
```

### Migration 2: Add Voiding Support to Mentorships
```ruby
class AddVoidingSupportToMentorships < ActiveRecord::Migration[7.0]
  def change
    add_column :mentorships, :ended_reason, :integer, null: true
    add_column :mentorships, :ended_at, :timestamp, null: true    
  end
end
```

## Backwards Compatibility

**Existing Data Protection:**
- All new columns are nullable to preserve existing records
- No changes to existing column definitions
- Enum defaults ensure valid states for existing records

**Query Compatibility:**
- Existing queries continue to work unchanged
- New columns can be safely ignored by existing code
- Indexes enhance performance without breaking functionality

**ULID Integration:**
- Import batch IDs will use ULID format for consistency: `ULID.generate`
- Foreign key references maintain Rails conventions
- Batch IDs stored as strings to support ULID format

**Email Tracking System:**
- No changes to existing 12-column email tracking in mentorships table
- Import process respects existing email sequence state
- Voided matches excluded from active email sequences

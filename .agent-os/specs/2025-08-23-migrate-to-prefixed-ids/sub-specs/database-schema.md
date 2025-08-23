# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-08-23-migrate-to-prefixed-ids/spec.md

## Migration Plan

### Phase 1: Add Integer Columns
```ruby
class AddIntegerIdsToTables < ActiveRecord::Migration[8.0]
  def change
    # Users table
    add_column :users, :new_id, :integer
    add_index :users, :new_id, unique: true
    
    # Mentorships table  
    add_column :mentorships, :new_id, :integer
    add_column :mentorships, :new_mentor_id, :integer
    add_column :mentorships, :new_applicant_id, :integer
    add_index :mentorships, :new_id, unique: true
    
    # Continue for all tables with ULID...
  end
end
```

### Phase 2: Populate Integer IDs
```ruby
class PopulateIntegerIds < ActiveRecord::Migration[8.0]
  def up
    # Populate users
    User.reset_column_information
    User.find_each.with_index(1) do |user, index|
      user.update_column(:new_id, index)
    end
    
    # Update foreign keys in mentorships
    Mentorship.find_each do |mentorship|
      mentor = User.find_by(id: mentorship.mentor_id)
      applicant = User.find_by(id: mentorship.applicant_id)
      mentorship.update_columns(
        new_mentor_id: mentor&.new_id,
        new_applicant_id: applicant&.new_id
      )
    end
  end
  
  def down
    # Remove populated values
  end
end
```

### Phase 3: Switch Primary Keys
```ruby
class SwitchToIntegerPrimaryKeys < ActiveRecord::Migration[8.0]
  def change
    # Remove old foreign key constraints
    remove_foreign_key :mentorships, :users, column: :mentor_id
    remove_foreign_key :mentorships, :users, column: :applicant_id
    
    # Rename columns
    rename_column :users, :id, :ulid_id
    rename_column :users, :new_id, :id
    
    rename_column :mentorships, :mentor_id, :ulid_mentor_id
    rename_column :mentorships, :new_mentor_id, :mentor_id
    rename_column :mentorships, :applicant_id, :ulid_applicant_id  
    rename_column :mentorships, :new_applicant_id, :applicant_id
    
    # Add new foreign keys
    add_foreign_key :mentorships, :users, column: :mentor_id
    add_foreign_key :mentorships, :users, column: :applicant_id
    
    # Set as primary key
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    execute "ALTER TABLE mentorships ADD PRIMARY KEY (id);"
  end
end
```

### Phase 4: Remove ULID Columns
```ruby
class RemoveUlidColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :ulid_id, :string
    remove_column :mentorships, :ulid_id, :string
    remove_column :mentorships, :ulid_mentor_id, :string
    remove_column :mentorships, :ulid_applicant_id, :string
    # Continue for all ULID columns...
  end
end
```

## Index Strategy

- Primary key indexes on all `id` columns
- Foreign key indexes on all relationship columns
- Composite indexes for frequently queried combinations
- Remove obsolete ULID indexes after migration

## Data Integrity

- Use database transactions for each migration phase
- Implement verification steps between phases
- Create backup before migration
- Test rollback procedures
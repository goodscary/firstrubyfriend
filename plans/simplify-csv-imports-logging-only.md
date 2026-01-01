# Simplify CSV Imports: Logging Only

## Overview

Remove all import tracking infrastructure. Replace with simple inline console output and boolean returns.

## Files to Delete

```
app/models/import_report.rb
app/models/import_result.rb
app/models/backfill_result.rb
app/jobs/import_job.rb
app/controllers/admin/imports_controller.rb
app/views/admin/imports/
db/migrate/*_create_import_reports.rb
test/models/import_report_test.rb
test/models/import_result_test.rb
test/models/backfill_result_test.rb
test/jobs/import_job_test.rb
test/controllers/admin/imports_controller_test.rb
```

## Files to Modify

### `app/models/concerns/csv_importable.rb`

Simplify to return boolean, log to Rails.logger:

```ruby
require "csv"

module CsvImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_csv(csv_content, rate_limit_delay: nil)
      imported = 0
      failed = 0

      csv = CSV.parse(csv_content, headers: true, header_converters: :downcase)

      missing = csv_import_required_headers - csv.headers.map(&:to_s)
      if missing.any?
        Rails.logger.error "[Import] Missing required headers: #{missing.join(', ')}"
        return false
      end

      csv.each_with_index do |row, index|
        sleep(rate_limit_delay) if rate_limit_delay && index > 0

        result = process_csv_row(row, index)
        if result[:success]
          imported += 1
        else
          failed += 1
          Rails.logger.info "[Import] Row #{index + 2}: #{result[:error]}"
        end
      end

      Rails.logger.info "[Import] Complete: #{imported} imported, #{failed} failed"
      failed == 0
    rescue CSV::MalformedCSVError => e
      Rails.logger.error "[Import] CSV parsing error: #{e.message}"
      false
    end

    private

    def csv_import_required_headers
      []
    end

    def process_csv_row(row, index)
      raise NotImplementedError, "Subclasses must implement process_csv_row"
    end
  end
end
```

### `app/models/user.rb`

Update import methods to remove `use_transaction:` and use inline header mapping:

```ruby
# Replace import_mentors_from_csv
def self.import_mentors_from_csv(csv_content, rate_limit_delay: 1)
  import_from_csv(csv_content, rate_limit_delay: rate_limit_delay)
end

# Replace import_applicants_from_csv
def self.import_applicants_from_csv(csv_content, rate_limit_delay: 1)
  import_from_csv(csv_content, rate_limit_delay: rate_limit_delay)
end

# Update process_csv_row to inline header mapping (remove map_csv_row call)
def self.process_csv_row(row, index)
  mapped = {}
  header_mapping.each { |csv_header, field| mapped[field] = row[csv_header]&.strip }
  # ... rest of existing logic
end
```

### `app/models/mentorship.rb`

Simplify import and backfill methods:

```ruby
def self.import_matches_from_csv(csv_content)
  import_from_csv(csv_content)
end

def self.backfill_email_dates
  processed = 0
  errors = 0

  find_each do |mentorship|
    result = mentorship.backfill_email_dates_for_mentorship
    if result[:success]
      processed += 1
    else
      errors += 1
      Rails.logger.info "[Backfill] Mentorship #{mentorship.id}: #{result[:error]}"
    end
  end

  Rails.logger.info "[Backfill] Complete: #{processed} processed, #{errors} errors"
  errors == 0
end
```

### `config/routes.rb`

Remove admin imports routes:

```ruby
# Delete this block:
namespace :admin do
  resources :imports, only: [:index, :new, :create, :show], param: :report_id
end
```

### `lib/tasks/imports.rake`

Simplified rake tasks with console output:

```ruby
namespace :imports do
  desc "Import mentors from CSV file"
  task :mentors, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:mentors[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing mentors from #{file_path}..."
    success = User.import_mentors_from_csv(File.read(file_path))
    exit(success ? 0 : 1)
  end

  desc "Import applicants from CSV file"
  task :applicants, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:applicants[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing applicants from #{file_path}..."
    success = User.import_applicants_from_csv(File.read(file_path))
    exit(success ? 0 : 1)
  end

  desc "Import matches from CSV file"
  task :matches, [:file_path] => :environment do |t, args|
    file_path = args[:file_path]
    abort "Usage: rails imports:matches[path/to/file.csv]" unless file_path && File.exist?(file_path)

    puts "Importing matches from #{file_path}..."
    success = Mentorship.import_matches_from_csv(File.read(file_path))

    if success
      puts "\nBackfilling email dates..."
      Mentorship.backfill_email_dates
    end

    exit(success ? 0 : 1)
  end

  desc "Backfill email dates for all mentorships"
  task backfill_emails: :environment do
    puts "Backfilling email dates..."
    success = Mentorship.backfill_email_dates
    exit(success ? 0 : 1)
  end

  desc "Full import workflow"
  task :full_import, [:mentors_file, :applicants_file, :matches_file] => :environment do |t, args|
    abort "Usage: rails imports:full_import[mentors.csv,applicants.csv,matches.csv]" unless args[:mentors_file] && args[:applicants_file] && args[:matches_file]

    [args[:mentors_file], args[:applicants_file], args[:matches_file]].each do |f|
      abort "File not found: #{f}" unless File.exist?(f)
    end

    puts "=== Importing Mentors ==="
    User.import_mentors_from_csv(File.read(args[:mentors_file]))

    puts "\n=== Importing Applicants ==="
    User.import_applicants_from_csv(File.read(args[:applicants_file]))

    puts "\n=== Importing Matches ==="
    Mentorship.import_matches_from_csv(File.read(args[:matches_file]))

    puts "\n=== Backfilling Email Dates ==="
    Mentorship.backfill_email_dates

    puts "\nDone!"
  end
end
```

### Database Migration

```ruby
class DropImportReports < ActiveRecord::Migration[8.0]
  def change
    drop_table :import_reports
  end
end
```

## What Gets Removed

| Component | Why |
|-----------|-----|
| `ImportReport` | Database persistence not needed for CLI |
| `ImportResult` | Return boolean instead |
| `BackfillResult` | Return boolean instead |
| `ImportJob` | No background processing needed |
| Admin web UI | No persistence = no history to show |
| `use_transaction:` param | Never used with `true` |
| `audit:` param | Complexity for unused feature |
| `map_csv_row` helper | Inline 3-line loop |
| `csv_import_missing_headers` helper | Inline one-liner |
| Report rake tasks | No persistence = no reports |

## What Gets Kept

- `CsvImportable` concern (simplified)
- User/Mentorship import methods (simplified)
- Core rake tasks (mentors, applicants, matches, backfill, full_import)
- All CSV processing logic in models
- Rate limiting for geocoding

## Acceptance Criteria

- [ ] `rails imports:mentors[file.csv]` works
- [ ] `rails imports:applicants[file.csv]` works
- [ ] `rails imports:matches[file.csv]` works
- [ ] `rails imports:backfill_emails` works
- [ ] `rails imports:full_import[m.csv,a.csv,match.csv]` works
- [ ] Exit codes: 0 success, 1 failure
- [ ] Errors logged via Rails.logger
- [ ] No ImportReport/ImportResult/BackfillResult classes
- [ ] No /admin/imports routes
- [ ] Tests updated and passing

## Test Updates Required

Update model tests to expect boolean returns instead of result objects:

```ruby
# Before
result = User.import_mentors_from_csv(csv)
assert result.success?
assert_equal 2, result.imported_count

# After
success = User.import_mentors_from_csv(csv)
assert success
assert_equal 2, User.where(available_as_mentor_at: ...).count
```

Remove tests for deleted classes:
- `test/models/import_report_test.rb`
- `test/models/import_result_test.rb`
- `test/models/backfill_result_test.rb`
- `test/jobs/import_job_test.rb`

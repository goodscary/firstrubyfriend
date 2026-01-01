# Simplify Match CSV Import to Essentials

## Overview

Simplify the match CSV import to only require the three essential fields: applicant email, mentor email, and match date. Remove all the "noise" (country, city, gone status, etc.) that isn't needed to create a match.

## Current State

**File:** `app/models/mentorship.rb:19-25`

```ruby
MATCH_CSV_HEADERS = {
  "applicant" => :applicant_email,
  "country" => :applicant_country,
  "city" => :applicant_city,
  "mentor" => :mentor_email,
  "gone" => :gone_status
}.freeze
```

**Required headers:** applicant, country, city, mentor
**Optional:** gone

The current implementation:
- Updates applicant location from CSV (unnecessary noise)
- Uses "Gone" column to set standing (unnecessary - always import as active)
- Validates 4 required columns when only 3 are needed

## Proposed State

```ruby
MATCH_CSV_HEADERS = {
  "applicant" => :applicant_email,
  "mentor" => :mentor_email
}.freeze
```

**Required headers:** applicant, mentor
**Match date:** Parsed from filename (e.g., "23-Sep-Table 1.csv") or passed as parameter
**Behavior:**
- Creates active mentorship between existing users
- Uses match_date parameter as `created_at` for the mentorship
- Ignores all other columns (Country, City, Gone, etc.)

## Acceptance Criteria

- [x] CSV only requires: Applicant, Mentor columns
- [x] Extra columns (Country, City, Gone, Date, etc.) are silently ignored
- [x] Match date from filename or parameter is used as `created_at` on the mentorship
- [x] All imported matches have standing: "active"
- [x] Existing behavior preserved: ends other active matches for same applicant
- [x] Existing behavior preserved: case-insensitive email lookup
- [x] Tests updated to reflect new minimal format

## Implementation

### 1. Update header mapping

**File:** `app/models/mentorship.rb:19-25`

```ruby
MATCH_CSV_HEADERS = {
  "applicant" => :applicant_email,
  "mentor" => :mentor_email,
  "date" => :match_date
}.freeze
```

### 2. Simplify required headers

**File:** `app/models/mentorship.rb:35-38`

```ruby
def self.csv_import_required_headers
  MATCH_CSV_HEADERS.keys  # All three are required
end
```

### 3. Simplify process_csv_row

**File:** `app/models/mentorship.rb:40-95`

Remove:
- Location update logic (lines 54-60)
- Country normalization call
- Gone status handling (lines 62-64)

Add:
- Date parsing with validation
- Set `created_at` from parsed date

```ruby
def self.process_csv_row(row, index)
  mapped_data = {}
  MATCH_CSV_HEADERS.each { |csv_header, field| mapped_data[field] = row[csv_header]&.strip }

  # Validate and parse date
  match_date = parse_match_date(mapped_data[:match_date])
  unless match_date
    return {success: false, error: "Invalid or missing date: #{mapped_data[:match_date]}"}
  end

  applicant = User.find_by("LOWER(email) = ?", mapped_data[:applicant_email]&.downcase)
  unless applicant
    return {success: false, error: "Applicant not found: #{mapped_data[:applicant_email]}"}
  end

  mentor = User.find_by("LOWER(email) = ?", mapped_data[:mentor_email]&.downcase)
  unless mentor
    return {success: false, error: "Mentor not found: #{mapped_data[:mentor_email]}"}
  end

  existing_mentorship = find_by(applicant: applicant, mentor: mentor)
  if existing_mentorship
    return {success: false, error: "Mentorship already exists between #{applicant.email} and #{mentor.email}"}
  end

  # End any other active mentorship for this applicant
  other_active = find_by(applicant: applicant, standing: "active")
  other_active&.update!(standing: "ended")

  mentorship = new(
    mentor: mentor,
    applicant: applicant,
    standing: "active",
    created_at: match_date
  )

  if mentorship.save
    {success: true, data: mentorship}
  else
    {success: false, error: "Failed to create mentorship: #{mentorship.errors.full_messages.join(", ")}"}
  end
rescue => e
  {success: false, error: "Error processing row: #{e.message}"}
end

def self.parse_match_date(date_string)
  return nil if date_string.blank?
  Date.parse(date_string)
rescue Date::Error
  nil
end
```

### 4. Remove normalize_country_code method

**File:** `app/models/mentorship.rb:97-110`

Delete the entire `normalize_country_code` method - no longer needed.

### 5. Update tests

**File:** `test/models/mentorship_test.rb`

Update test fixtures to use new minimal format:

```ruby
@valid_csv = CSV.generate do |csv|
  csv << ["Applicant", "Mentor", "Date"]
  csv << ["import_applicant1@example.com", "import_mentor1@example.com", "2024-01-15"]
  csv << ["import_applicant2@example.com", "import_mentor2@example.com", "2024-02-20"]
end
```

Add test for date validation:

```ruby
test "fails with missing or invalid date" do
  invalid_date_csv = CSV.generate do |csv|
    csv << ["Applicant", "Mentor", "Date"]
    csv << ["import_applicant1@example.com", "import_mentor1@example.com", ""]
  end

  success = Mentorship.import_matches_from_csv(invalid_date_csv)
  assert_not success
end
```

Add test for created_at from CSV date:

```ruby
test "sets created_at from CSV date" do
  csv = CSV.generate do |csv|
    csv << ["Applicant", "Mentor", "Date"]
    csv << ["import_applicant1@example.com", "import_mentor1@example.com", "2023-06-15"]
  end

  Mentorship.import_matches_from_csv(csv)

  mentorship = Mentorship.find_by(applicant: @test_applicant1, mentor: @test_mentor1)
  assert_equal Date.new(2023, 6, 15), mentorship.created_at.to_date
end
```

## Files Changed

| File | Action |
|------|--------|
| `app/models/mentorship.rb` | Simplify headers, process_csv_row, remove normalize_country_code |
| `test/models/mentorship_test.rb` | Update test fixtures, add date tests |

## References

- Current implementation: `app/models/mentorship.rb:19-110`
- CsvImportable concern: `app/models/concerns/csv_importable.rb`
- Existing tests: `test/models/mentorship_test.rb:91-314`

# Oaken Test Seed Data
#
# This file contains all test seed data for the FirstRubyFriend test suite.
# Converted from YAML fixtures to Ruby-based Oaken seeds.
#
# These seeds are loaded at the beginning of the test suite to establish a
# "known state" for all tests, replacing the previous YAML fixture approach.
#
# Fixture compatibility: Seeds can be referenced in tests using the same
# syntax as YAML fixtures (e.g., users(:basic), languages(:english))

# Users
# All users use the same test password for consistency
users.create :basic,
  email: "basic@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: true

users.create :mentor,
  email: "mentor@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: true

users.create :applicant,
  email: "applicant@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: true

users.create :unverified,
  email: "unverified@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: false

users.create :with_location,
  email: "located@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: true,
  city: "Brighton",
  country_code: "GB",
  lat: 50.827778,
  lng: -0.152778,
  demographic_year_started_ruby: 2023,
  demographic_year_started_programming: 2022,
  demographic_underrepresented_group: false

users.create :github_user,
  email: "github_user@example.com",
  password_digest: BCrypt::Password.create("Secret1*3*5*"),
  verified: true,
  provider: "github",
  uid: "123456"

# Languages
languages.create :english,
  iso639_alpha3: "eng",
  iso639_alpha2: "en",
  english_name: "English",
  french_name: "anglais",
  local_name: "English"

languages.create :spanish,
  iso639_alpha3: "spa",
  iso639_alpha2: "es",
  english_name: "Spanish",
  french_name: "espagnol",
  local_name: "Espanol"

# Mentorships
mentorships.create :active_no_emails_sent,
  mentor: users.mentor,
  applicant: users.applicant,
  standing: "active"

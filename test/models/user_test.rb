require "test_helper"
require "csv"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users.with_location
    Current.user_agent = "Mozilla/5.0 Test Browser"
    Current.ip_address = "127.0.0.1"
  end

  class Validations < UserTest
    test "rejects nil email" do
      @user.email = nil
      assert_not @user.valid?
    end

    test "rejects duplicate email" do
      duplicate_user = @user.dup
      assert_not duplicate_user.valid?
    end

    test "rejects invalid email format" do
      invalid_emails = %w[user@example,com user_at_example.org user.name@example.]
      invalid_emails.each do |invalid_email|
        @user.email = invalid_email
        assert_not @user.valid?
      end
    end

    test "accepts valid latitude and longitude" do
      valid_lat = rand(-90..90)
      valid_lng = rand(-180..180)
      @user.lat = valid_lat
      @user.lng = valid_lng

      assert @user.valid?
    end

    test "rejects invalid latitude" do
      @user.lat = 91
      assert_not @user.valid?
    end

    test "rejects invalid longitude" do
      @user.lng = 181
      assert_not @user.valid?
    end
  end

  class UnsubscribedReason < UserTest
    test "accepts valid unsubscribed_reason enum options" do
      valid_reasons = User.unsubscribed_reasons.keys
      valid_reasons.each do |valid_reason|
        @user.unsubscribed_reason = valid_reason
        assert @user.valid?
      end
    end

    test "rejects invalid unsubscribed_reason" do
      assert_raises(ArgumentError) { @user.unsubscribed_reason = "invalid_reason" }
    end
  end

  class PrefixedId < UserTest
    test "generates prefixed ID with usr_ prefix" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      assert user.prefix_id.start_with?("usr_")
      assert user.prefix_id.length > 4
    end

    test "finds user by prefixed ID" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      found_user = User.find_by_prefix_id(user.prefix_id)
      assert_equal user, found_user
    end

    test "returns nil for invalid prefixed ID" do
      result = User.find_by_prefix_id("usr_invalid")
      assert_nil result
    end

    test "is stable for same record" do
      user = User.create!(email: "test@example.com", password: "SecurePassword123*&^")
      prefixed_id_1 = user.prefix_id
      user.reload
      prefixed_id_2 = user.prefix_id
      assert_equal prefixed_id_1, prefixed_id_2
    end
  end

  class Callbacks < UserTest
    test "downcases and strips email before validation" do
      user = User.new(email: "  TEST@EXAMPLE.COM  ", password: "SecurePassword123*&^")
      user.valid?
      assert_equal "test@example.com", user.email
    end

    test "sets verified to false when email changes on update" do
      @user.update!(verified: true)
      @user.update!(email: "changed@example.com")

      assert_not @user.verified
    end

    test "creates email_verification_requested event when email changes" do
      @user.update!(email: "newemail@example.com")

      event = Event.last
      assert_equal "email_verification_requested", event.action
      assert_equal @user, event.user
    end

    test "creates password_changed event when password changes" do
      @user.update!(password: "NewSecurePassword123*&^")

      event = Event.last
      assert_equal "password_changed", event.action
      assert_equal @user, event.user
    end

    test "deletes other sessions when password changes" do
      session1 = @user.sessions.create!
      session2 = @user.sessions.create!
      Current.session = session1

      @user.update!(password: "NewSecurePassword123*&^")

      assert Session.exists?(session1.id)
      assert_not Session.exists?(session2.id)
    end

    test "creates email_verified event when verified becomes true" do
      unverified_user = users.unverified
      unverified_user.update!(verified: true)

      event = Event.last
      assert_equal "email_verified", event.action
      assert_equal unverified_user, event.user
    end
  end

  class MentorPredicate < UserTest
    test "returns true when available_as_mentor_at is present" do
      @user.update!(available_as_mentor_at: Time.current)
      assert @user.mentor?
    end

    test "returns true when has mentorship_roles_as_mentor" do
      mentor = users.mentor
      applicant = users.applicant
      Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert mentor.mentor?
    end

    test "returns false when not a mentor" do
      @user.available_as_mentor_at = nil
      assert_not @user.mentor?
    end
  end

  class ApplicantPredicate < UserTest
    test "returns true when requested_mentorship_at is present" do
      @user.update!(requested_mentorship_at: Time.current)
      assert @user.applicant?
    end

    test "returns true when has mentorship_roles_as_applicant" do
      applicant = users.applicant
      mentor = users.mentor
      Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert applicant.applicant?
    end

    test "returns false when not an applicant" do
      @user.requested_mentorship_at = nil
      assert_not @user.applicant?
    end
  end

  class Address < UserTest
    test "returns city and country code" do
      @user.city = "London"
      @user.country_code = "GB"
      assert_equal "London, GB", @user.address
    end

    test "returns only city when country_code is nil" do
      @user.city = "London"
      @user.country_code = nil
      assert_equal "London", @user.address
    end

    test "returns only country_code when city is nil" do
      @user.city = nil
      @user.country_code = "GB"
      assert_equal "GB", @user.address
    end

    test "returns empty string when both nil" do
      @user.city = nil
      @user.country_code = nil
      assert_equal "", @user.address
    end
  end

  class ActiveMentorship < UserTest
    test "returns active_mentor if present" do
      mentor = users.mentor
      applicant = users.applicant
      mentorship = Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert_equal mentorship, mentor.active_mentorship
    end

    test "returns active_applicant if no active mentor" do
      applicant = users.applicant
      mentor = users.mentor
      mentorship = Mentorship.find_or_create_by!(mentor: mentor, applicant: applicant, standing: "active")

      assert_equal mentorship, applicant.active_mentorship
    end

    test "returns nil when no active mentorship" do
      assert_nil @user.active_mentorship
    end
  end

  class MailcoachSubscription < UserTest
    include ActiveJob::TestHelper

    test "enqueues mailcoach subscription job after create" do
      assert_enqueued_with(job: User::SubscribeToMailcoachJob) do
        User.create!(email: "newuser@example.com", password: "SecurePassword123*&^")
      end
    end

    test "subscribe_to_mailcoach handles missing credentials gracefully" do
      # When credentials are missing, MailcoachClient.new raises MissingCredentials
      # The subscribe_to_mailcoach method should rescue this and log a warning
      assert_nothing_raised do
        @user.subscribe_to_mailcoach
      end
    end

    test "responds to subscribe_to_mailcoach_later" do
      assert_respond_to @user, :subscribe_to_mailcoach_later
    end
  end

  class ImportApplicantsFromCsv < UserTest
    setup do
      @valid_csv = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What year were you born?",
          "What year did you first start programming?", "What year did you first start using Ruby?",
          "Do you self-identify as a member of an underrepresented group in tech?",
          "If you feel comfortable, please share which group(s) you identify with",
          "What is your current level of Ruby experience?", "Where do you currently live? (City, Country)",
          "Are you currently writing Ruby regularly?", "How did you get started with programming in general?",
          "What do you want to get out of being mentored?", "Any links you'd like to share?"]
        csv << ["2023-03-01", "Alice", "Johnson", "alice@example.com", "1995",
          "2018", "2022", "Yes", "Women in tech",
          "Junior", "Portland, OR", "Yes", "Bootcamp",
          "Career guidance and code reviews", "https://github.com/alicej"]
        csv << ["2023-03-15", "Bob", "Smith", "bob@example.com", "1990",
          "2015", "2021", "No", "",
          "Intermediate", "Denver, CO", "No", "Self-taught",
          "Best practices and architecture", ""]
      end

      @missing_headers_csv = CSV.generate do |csv|
        csv << ["Date", "Name", "Email"]
        csv << ["2023-03-01", "Alice Johnson", "alice@example.com"]
      end
    end

    test "imports applicants successfully" do
      assert_difference "User.count", 2 do
        result = User.import_applicants_from_csv(@valid_csv)
        assert result.success?
        assert_equal 2, result.imported_count
      end

      alice = User.find_by(email: "alice@example.com")
      assert_equal "Alice", alice.first_name
      assert_equal "Johnson", alice.last_name
      assert alice.requested_mentorship_at.present?
      assert_equal 1995, alice.demographic_year_of_birth
      assert_equal 2018, alice.demographic_year_started_programming
      assert_equal 2022, alice.demographic_year_started_ruby
      assert alice.demographic_underrepresented_group
      assert_equal "Women in tech", alice.demographic_underrepresented_group_details
      assert_equal "Portland, OR", alice.questionnaire_responses["location"]
      assert_equal "Junior", alice.questionnaire_responses["ruby_experience"]
      assert_equal true, alice.questionnaire_responses["currently_writing_ruby"]
      assert_equal "Bootcamp", alice.questionnaire_responses["how_started"]
      assert_equal "Career guidance and code reviews", alice.questionnaire_responses["mentorship_goals"]
      assert_equal "https://github.com/alicej", alice.questionnaire_responses["links"]
    end

    test "validates required headers" do
      result = User.import_applicants_from_csv(@missing_headers_csv)

      assert_not result.success?
      assert result.errors.any? { |e| e.include?("Missing required headers") }
    end

    test "creates users without passwords" do
      User.import_applicants_from_csv(@valid_csv)

      alice = User.find_by(email: "alice@example.com")
      assert_nil alice.password_digest
    end

    test "handles boolean values correctly" do
      User.import_applicants_from_csv(@valid_csv)

      alice = User.find_by(email: "alice@example.com")
      assert alice.demographic_underrepresented_group
      assert_equal true, alice.questionnaire_responses["currently_writing_ruby"]

      bob = User.find_by(email: "bob@example.com")
      assert_not bob.demographic_underrepresented_group
      assert_equal false, bob.questionnaire_responses["currently_writing_ruby"]
    end

    test "parses years as integers" do
      User.import_applicants_from_csv(@valid_csv)

      alice = User.find_by(email: "alice@example.com")
      assert_kind_of Integer, alice.demographic_year_of_birth
      assert_equal 1995, alice.demographic_year_of_birth
      assert_equal 2018, alice.demographic_year_started_programming
      assert_equal 2022, alice.demographic_year_started_ruby
    end

    test "handles missing optional fields" do
      csv_with_missing = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What year were you born?",
          "What year did you first start programming?", "What year did you first start using Ruby?",
          "Do you self-identify as a member of an underrepresented group in tech?",
          "If you feel comfortable, please share which group(s) you identify with",
          "What is your current level of Ruby experience?", "Where do you currently live? (City, Country)",
          "Are you currently writing Ruby regularly?", "How did you get started with programming in general?",
          "What do you want to get out of being mentored?", "Any links you'd like to share?"]
        csv << ["2023-03-01", "Charlie", "Brown", "charlie@example.com", "",
          "", "", "No", "",
          "Beginner", "Austin, TX", "Yes", "University",
          "Learn Ruby basics", ""]
      end

      result = User.import_applicants_from_csv(csv_with_missing)

      assert result.success?
      charlie = User.find_by(email: "charlie@example.com")
      assert_nil charlie.demographic_year_of_birth
      assert_nil charlie.demographic_year_started_programming
      assert_nil charlie.demographic_year_started_ruby
    end

    test "maps location data correctly" do
      User.import_applicants_from_csv(@valid_csv)

      alice = User.find_by(email: "alice@example.com")
      assert_equal "Portland, OR", alice.questionnaire_responses["location"]
    end
  end

  class ImportMentorsFromCsv < UserTest
    setup do
      @valid_csv = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What company do you work for or what do you do?",
          "Where do you work?", "Location (Where do you currently live?)", "Previous Location",
          "Confirmed location", "Links", "Who would you prefer to mentor",
          "How many people would you prefer to mentor simultaneously?", "Languages you feel comfortable mentoring in"]
        csv << ["2023-01-15", "John", "Doe", "john@example.com", "Acme Corp",
          "Remote", "San Francisco, CA", "New York, NY", "San Francisco, CA",
          "https://github.com/johndoe", "Junior developers", "2", "English, Spanish"]
        csv << ["2023-02-20", "Jane", "Smith", "jane@example.com", "Tech Co",
          "Office", "Austin, TX", "", "Austin, TX",
          "https://linkedin.com/in/janesmith", "Career changers", "1", "English"]
      end

      @missing_headers_csv = CSV.generate do |csv|
        csv << ["Date", "Name", "Email"]
        csv << ["2023-01-15", "John Doe", "john@example.com"]
      end

      @duplicate_email_csv = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What company do you work for or what do you do?",
          "Where do you work?", "Location (Where do you currently live?)", "Previous Location",
          "Confirmed location", "Links", "Who would you prefer to mentor",
          "How many people would you prefer to mentor simultaneously?", "Languages you feel comfortable mentoring in"]
        csv << ["2023-01-15", "John", "Doe", "john@example.com", "Acme Corp",
          "Remote", "San Francisco, CA", "New York, NY", "San Francisco, CA",
          "https://github.com/johndoe", "Junior developers", "2", "English, Spanish"]
        csv << ["2023-03-10", "Johnny", "Doe", "john@example.com", "New Corp",
          "Hybrid", "San Francisco, CA", "Los Angeles, CA", "San Francisco, CA",
          "https://github.com/johnnydoe", "Senior developers", "3", "English, French"]
      end
    end

    test "imports mentors successfully" do
      assert_difference "User.count", 2 do
        result = User.import_mentors_from_csv(@valid_csv)
        assert result.success?
        assert_equal 2, result.imported_count
      end

      john = User.find_by(email: "john@example.com")
      assert_equal "John", john.first_name
      assert_equal "Doe", john.last_name
      assert john.available_as_mentor_at.present?
      assert_equal "Acme Corp", john.questionnaire_responses["company"]
      assert_equal "San Francisco, CA", john.questionnaire_responses["location"]
      assert_equal ["English", "Spanish"], john.questionnaire_responses["languages"]
      assert_equal 2, john.questionnaire_responses["max_mentees"]
    end

    test "validates required headers" do
      result = User.import_mentors_from_csv(@missing_headers_csv)

      assert_not result.success?
      assert result.errors.any? { |e| e.include?("Missing required headers") }
    end

    test "creates users without passwords" do
      User.import_mentors_from_csv(@valid_csv)

      john = User.find_by(email: "john@example.com")
      assert_nil john.password_digest
    end

    test "handles duplicate emails by updating existing record" do
      assert_difference "User.count", 1 do
        result = User.import_mentors_from_csv(@duplicate_email_csv)
        assert result.success?
        assert_equal 2, result.imported_count
      end

      john = User.find_by(email: "john@example.com")
      assert_equal "Johnny", john.first_name
      assert_equal "New Corp", john.questionnaire_responses["company"]
      assert_equal 3, john.questionnaire_responses["max_mentees"]
    end

    test "handles invalid email formats" do
      invalid_csv = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What company do you work for or what do you do?",
          "Where do you work?", "Location (Where do you currently live?)", "Previous Location",
          "Confirmed location", "Links", "Who would you prefer to mentor",
          "How many people would you prefer to mentor simultaneously?", "Languages you feel comfortable mentoring in"]
        csv << ["2023-01-15", "Invalid", "User", "not-an-email", "Company",
          "Remote", "Location", "", "Location",
          "", "Anyone", "1", "English"]
      end

      result = User.import_mentors_from_csv(invalid_csv)

      assert_not result.success?
      assert_equal 0, result.imported_count
      assert_equal 1, result.failed_count
      assert result.row_errors.any? { |e| e[:error].include?("Invalid email") }
    end

    test "maps CSV fields to questionnaire responses" do
      User.import_mentors_from_csv(@valid_csv)

      john = User.find_by(email: "john@example.com")
      responses = john.questionnaire_responses

      assert_equal "Acme Corp", responses["company"]
      assert_equal "Remote", responses["work_location"]
      assert_equal "San Francisco, CA", responses["location"]
      assert_equal "New York, NY", responses["previous_location"]
      assert_equal "https://github.com/johndoe", responses["links"]
      assert_equal "Junior developers", responses["mentee_preference"]
      assert_equal 2, responses["max_mentees"]
      assert_equal ["English", "Spanish"], responses["languages"]
    end

    test "uses transaction for rollback on failure" do
      csv_with_error = CSV.generate do |csv|
        csv << ["Date", "First name", "Last name", "Email", "What company do you work for or what do you do?",
          "Where do you work?", "Location (Where do you currently live?)", "Previous Location",
          "Confirmed location", "Links", "Who would you prefer to mentor",
          "How many people would you prefer to mentor simultaneously?", "Languages you feel comfortable mentoring in"]
        csv << ["2023-01-15", "Valid", "User", "valid@example.com", "Company",
          "Remote", "Location", "", "Location",
          "", "Anyone", "1", "English"]
        csv << ["2023-01-16", "", "", "missing-names@example.com", "Company",
          "Remote", "Location", "", "Location",
          "", "Anyone", "1", "English"]
      end

      assert_no_difference "User.count" do
        result = User.import_mentors_from_csv(csv_with_error, use_transaction: true)
        assert_not result.success?
      end
    end
  end
end

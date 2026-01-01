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
        csv << ["Date", "What's your name?", "What's your email?", "Country", "City",
          "Are you working anywhere yet?", "Are you writing Ruby there?", "Where'd you get your start?",
          "Would you consider yourself in an underrepresented group?", "Twitter?", "Github?",
          "Do you have a personal site?", "Any languages other than English?",
          "What did you do before you became a programmer?", "What are you looking to get out of the mentoring?",
          "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2023-03-01", "Alice Johnson", "alice@example.com", "US", "Portland",
          "https://techcorp.com", "Yes", "Bootcamp",
          "Yes", "@alicej", "alicej",
          "https://alice.dev", "Spanish",
          "Marketing manager", "Career guidance and code reviews",
          "Yes", "Women in tech", "woman"]
        csv << ["2023-03-15", "Bob Smith", "bob@example.com", "UK", "London",
          "", "No", "Self-taught",
          "No", "", "bobsmith",
          "", "",
          "Student", "Best practices and architecture",
          "No", "", "man"]
      end

      @missing_headers_csv = CSV.generate do |csv|
        csv << ["Date", "Name", "Email"]
        csv << ["2023-03-01", "Alice Johnson", "alice@example.com"]
      end
    end

    test "imports applicants successfully" do
      assert_difference "User.count", 2 do
        success = User.import_applicants_from_csv(@valid_csv)
        assert success
      end

      alice = User.find_by(email: "alice@example.com")
      assert_equal "Alice", alice.first_name
      assert_equal "Johnson", alice.last_name
      assert alice.requested_mentorship_at.present?
      assert alice.demographic_underrepresented_group
      assert_equal "Portland", alice.city
      assert_equal "US", alice.country_code
      assert_equal "https://techcorp.com", alice.questionnaire_responses["current_employer"]
      assert_equal true, alice.questionnaire_responses["currently_writing_ruby"]
      assert_equal "Bootcamp", alice.questionnaire_responses["how_started"]
      assert_equal "Career guidance and code reviews", alice.questionnaire_responses["mentorship_goals"]
      assert_equal "@alicej", alice.questionnaire_responses["twitter_handle"]
      assert_equal "alicej", alice.questionnaire_responses["github_handle"]
    end

    test "validates required headers" do
      success = User.import_applicants_from_csv(@missing_headers_csv)
      assert_not success
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

    test "handles missing optional fields" do
      csv_with_missing = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Country", "City",
          "Are you working anywhere yet?", "Are you writing Ruby there?", "Where'd you get your start?",
          "Would you consider yourself in an underrepresented group?", "Twitter?", "Github?",
          "Do you have a personal site?", "Any languages other than English?",
          "What did you do before you became a programmer?", "What are you looking to get out of the mentoring?",
          "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2023-03-01", "Charlie Brown", "charlie@example.com", "US", "Austin",
          "", "Yes", "University",
          "No", "", "",
          "", "",
          "", "Learn Ruby basics",
          "No", "", ""]
      end

      success = User.import_applicants_from_csv(csv_with_missing)

      assert success
      charlie = User.find_by(email: "charlie@example.com")
      assert_nil charlie.questionnaire_responses["current_employer"]
      assert_nil charlie.questionnaire_responses["twitter_handle"]
      assert_nil charlie.questionnaire_responses["github_handle"]
    end

    test "maps questionnaire responses correctly" do
      User.import_applicants_from_csv(@valid_csv)

      alice = User.find_by(email: "alice@example.com")
      responses = alice.questionnaire_responses

      assert_equal "https://techcorp.com", responses["current_employer"]
      assert_equal true, responses["currently_writing_ruby"]
      assert_equal "Bootcamp", responses["how_started"]
      assert_equal "@alicej", responses["twitter_handle"]
      assert_equal "alicej", responses["github_handle"]
      assert_equal "https://alice.dev", responses["personal_site"]
      assert_equal "Spanish", responses["languages"]
      assert_equal "Marketing manager", responses["previous_career"]
      assert_equal "Career guidance and code reviews", responses["mentorship_goals"]
      assert_equal true, responses["wnb_member"]
      assert_equal "Women in tech", responses["demographic_preference"]
      assert_equal "woman", responses["self_description"]
    end

    test "imports real-world CSV format with URL-style entries" do
      # This tests the actual format from the Tally form export
      real_csv = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Country", "City",
          "Are you working anywhere yet?", "Are you writing Ruby there?", "Where'd you get your start?",
          "Would you consider yourself in an underrepresented group?", "Twitter?", "Github?",
          "Do you have a personal site?", "Any languages other than English?",
          "What did you do before you became a programmer?", "What are you looking to get out of the mentoring?",
          "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2025-03-09 19:55:37", "Moein Amin", "moein@example.com", "Iran", "Tehran",
          "https://no", "No", "I am a CS student but mostly self-taught",
          "No", "", "",
          "", "Farsi",
          "", "Career advice and first principle thinkings",
          "No", "", ""]
        csv << ["2025-03-11 15:35:29", "Javier Garcia", "javier@example.com", "Spain", "Coruña",
          "https://inditex.com", "No", "Self-taught",
          "No", "", "",
          "nightlydev.io", "I speak Spanish and English",
          "I was a salesman at a sport department store (Decathlon).",
          "I'm just starting my Ruby journey, and I would love to change my job to a Ruby one.",
          "No", "", "man"]
        csv << ["2025-03-18 10:46:48", "Summer", "summer@example.com", "Philippines", "City of San Fernando",
          "https://i-am-still-a-student-im-not-working.com", "Yes", "still a student, but learning ror through self study only",
          "yes", "none", "summer-rem",
          "none", "filipino and english",
          "accounting", "looking for help to learn the language since it is currently being used in my internship",
          "Yes", "", "woman"]
      end

      assert_difference "User.count", 3 do
        success = User.import_applicants_from_csv(real_csv)
        assert success
      end

      # Verify the URL-like "no" entries are handled
      moein = User.find_by(email: "moein@example.com")
      assert_equal "Moein", moein.first_name
      assert_equal "Amin", moein.last_name
      assert_equal "Tehran", moein.city
      assert_equal "IR", moein.country_code
      assert_equal "https://no", moein.questionnaire_responses["current_employer"]
      assert_equal false, moein.questionnaire_responses["currently_writing_ruby"]

      # Verify case-insensitive boolean parsing
      summer = User.find_by(email: "summer@example.com")
      assert_equal "Summer", summer.first_name
      assert summer.demographic_underrepresented_group
      assert_equal true, summer.questionnaire_responses["wnb_member"]
      assert_equal "woman", summer.questionnaire_responses["self_description"]
    end
  end

  class ImportMentorsFromCsv < UserTest
    setup do
      @valid_csv = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Where do you work?",
          "Year you started programming in Ruby", "Country", "City", "Twitter?", "Github?",
          "Do you have a personal site?", "Worked anywhere else?", "Why are you doing this?",
          "Have you done any mentoring before?", "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2023-01-15", "John Doe", "john@example.com", "https://acme.com",
          "2015", "US", "San Francisco", "@johndoe", "johndoe",
          "https://johndoe.com", "Previous Corp, Other Inc", "I want to help!",
          "Yes", "No", "Junior developers", "Senior developer"]
        csv << ["2023-02-20", "Jane Smith", "jane@example.com", "https://techco.com",
          "2018", "UK", "London", "@janesmith", "janesmith",
          "", "BigCorp", "Give back to community",
          "No", "Yes", "", "Mid-level developer"]
      end

      @missing_headers_csv = CSV.generate do |csv|
        csv << ["Date", "Name", "Email"]
        csv << ["2023-01-15", "John Doe", "john@example.com"]
      end

      @duplicate_email_csv = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Where do you work?",
          "Year you started programming in Ruby", "Country", "City", "Twitter?", "Github?",
          "Do you have a personal site?", "Worked anywhere else?", "Why are you doing this?",
          "Have you done any mentoring before?", "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2023-01-15", "John Doe", "john@example.com", "https://acme.com",
          "2015", "US", "San Francisco", "@johndoe", "johndoe",
          "https://johndoe.com", "Previous Corp", "I want to help!",
          "Yes", "No", "", "Senior developer"]
        csv << ["2023-03-10", "Johnny Doe", "john@example.com", "https://newcorp.com",
          "2010", "US", "San Francisco", "@johnnydoe", "johnnydoe",
          "", "Previous Corp, New Inc", "Still want to help!",
          "Yes", "No", "", "Principal developer"]
      end
    end

    test "imports mentors successfully" do
      assert_difference "User.count", 2 do
        success = User.import_mentors_from_csv(@valid_csv)
        assert success
      end

      john = User.find_by(email: "john@example.com")
      assert_equal "John", john.first_name
      assert_equal "Doe", john.last_name
      assert john.available_as_mentor_at.present?
      assert_equal "https://acme.com", john.questionnaire_responses["company"]
      assert_equal "San Francisco", john.city
      assert_equal "US", john.country_code
      assert_equal 2015, john.demographic_year_started_ruby
    end

    test "validates required headers" do
      success = User.import_mentors_from_csv(@missing_headers_csv)
      assert_not success
    end

    test "creates users without passwords" do
      User.import_mentors_from_csv(@valid_csv)

      john = User.find_by(email: "john@example.com")
      assert_nil john.password_digest
    end

    test "handles duplicate emails by updating existing record" do
      assert_difference "User.count", 1 do
        success = User.import_mentors_from_csv(@duplicate_email_csv)
        assert success
      end

      john = User.find_by(email: "john@example.com")
      assert_equal "Johnny", john.first_name
      assert_equal "https://newcorp.com", john.questionnaire_responses["company"]
      assert_equal 2010, john.demographic_year_started_ruby
    end

    test "handles invalid email formats" do
      invalid_csv = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Where do you work?",
          "Year you started programming in Ruby", "Country", "City", "Twitter?", "Github?",
          "Do you have a personal site?", "Worked anywhere else?", "Why are you doing this?",
          "Have you done any mentoring before?", "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2023-01-15", "Invalid User", "not-an-email", "https://company.com",
          "2015", "US", "Location", "", "",
          "", "", "Reason",
          "No", "No", "", ""]
      end

      success = User.import_mentors_from_csv(invalid_csv)
      assert_not success
    end

    test "maps CSV fields to questionnaire responses" do
      User.import_mentors_from_csv(@valid_csv)

      john = User.find_by(email: "john@example.com")
      responses = john.questionnaire_responses

      assert_equal "https://acme.com", responses["company"]
      assert_equal "@johndoe", responses["twitter_handle"]
      assert_equal "johndoe", responses["github_handle"]
      assert_equal "https://johndoe.com", responses["personal_site"]
      assert_equal "Previous Corp, Other Inc", responses["previous_workplaces"]
      assert_equal "I want to help!", responses["mentoring_reason"]
      assert_equal true, responses["has_mentored_before"]
      assert_equal false, responses["wnb_member"]
      assert_equal "Junior developers", responses["demographic_preference"]
      assert_equal "Senior developer", responses["self_description"]
    end

    test "imports real-world mentor CSV format" do
      # This tests the actual format from the Tally form export
      real_csv = CSV.generate do |csv|
        csv << ["Date", "What's your name?", "What's your email?", "Where do you work?",
          "Year you started programming in Ruby", "Country", "City", "Twitter?", "Github?",
          "Do you have a personal site?", "Worked anywhere else?", "Why are you doing this?",
          "Have you done any mentoring before?", "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
          "Do you have a strong preference to mentor someone from a particular demographic?",
          "How would you describe yourself?"]
        csv << ["2022-07-17 10:50:24", "Emma Barnes", "emma@example.com", "https://consonance.app",
          "2011", "uk", "Oxford", "@has_many_books", "EmmaB",
          "", "Snowbooks, Make our book, previously Deloitte and Kingfisher plc", "because andy comes up with good ideas and I want in",
          "", "", "", ""]
        csv << ["2022-07-17 14:52:26", "Tom Stuart", "tom@example.com", "https://www.shopify.com/",
          "2005", "UK", "London", "@tomstuart", "https://github.com/tomstuart",
          "https://tomstu.art/", "BBC, Berg, Econsultancy, FutureLearn, Government Digital Service, Ministry of Justice, Newspaper Club", "I want to help!",
          "Yes", "", "", ""]
        csv << ["2022-07-19 08:48:43", "George Sheppard", "george@example.com", "https://www.treecard.org/",
          "2009", "UK", "London", "@fuzzmonkey", "https://github.com/fuzzmonkey",
          "", "banked.com\nmeetcleo.com", "I've got so much from the Ruby community over the last 12+ years and keen to something to give back if i can!",
          "Yes", "", "", ""]
      end

      assert_difference "User.count", 3 do
        success = User.import_mentors_from_csv(real_csv)
        assert success
      end

      # Verify case-insensitive country codes
      emma = User.find_by(email: "emma@example.com")
      assert_equal "Emma", emma.first_name
      assert_equal "Barnes", emma.last_name
      assert_equal "Oxford", emma.city
      assert_equal "GB", emma.country_code  # "uk" → "GB"
      assert_equal 2011, emma.demographic_year_started_ruby
      assert_equal "https://consonance.app", emma.questionnaire_responses["company"]
      assert_equal "@has_many_books", emma.questionnaire_responses["twitter_handle"]

      # Verify GitHub URLs are stored as-is
      tom = User.find_by(email: "tom@example.com")
      assert_equal "https://github.com/tomstuart", tom.questionnaire_responses["github_handle"]
      assert_equal "https://tomstu.art/", tom.questionnaire_responses["personal_site"]
      assert_equal 2005, tom.demographic_year_started_ruby
      assert_equal true, tom.questionnaire_responses["has_mentored_before"]

      # Verify multiline text is preserved
      george = User.find_by(email: "george@example.com")
      assert george.questionnaire_responses["previous_workplaces"].include?("banked.com")
      assert george.questionnaire_responses["previous_workplaces"].include?("meetcleo.com")
    end

  end
end

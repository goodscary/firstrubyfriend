require "test_helper"
require "csv"

class MentorImporterTest < ActiveSupport::TestCase
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
    importer = MentorImporter.new(@valid_csv)

    assert_difference "User.count", 2 do
      result = importer.import
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
    importer = MentorImporter.new(@missing_headers_csv)
    result = importer.import

    assert_not result.success?
    assert result.errors.any? { |e| e.include?("Missing required headers") }
  end

  test "creates users without passwords" do
    importer = MentorImporter.new(@valid_csv)
    importer.import

    john = User.find_by(email: "john@example.com")
    assert_nil john.password_digest
  end

  test "handles duplicate emails by updating existing record" do
    importer = MentorImporter.new(@duplicate_email_csv)

    assert_difference "User.count", 1 do
      result = importer.import
      assert result.success?
      assert_equal 2, result.imported_count
    end

    john = User.find_by(email: "john@example.com")
    assert_equal "Johnny", john.first_name # Should have the latest data
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

    importer = MentorImporter.new(invalid_csv)
    result = importer.import

    assert_not result.success?
    assert_equal 0, result.imported_count
    assert_equal 1, result.failed_count
    assert result.row_errors.any? { |e| e[:error].include?("Invalid email") }
  end

  test "maps CSV fields to questionnaire responses" do
    importer = MentorImporter.new(@valid_csv)
    importer.import

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

    importer = MentorImporter.new(csv_with_error, use_transaction: true)

    assert_no_difference "User.count" do
      result = importer.import
      assert_not result.success?
    end
  end
end

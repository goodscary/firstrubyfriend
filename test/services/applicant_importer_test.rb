require "test_helper"
require "csv"

class ApplicantImporterTest < ActiveSupport::TestCase
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
    importer = ApplicantImporter.new(@valid_csv)

    assert_difference "User.count", 2 do
      result = importer.import
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
    importer = ApplicantImporter.new(@missing_headers_csv)
    result = importer.import

    assert_not result.success?
    assert result.errors.any? { |e| e.include?("Missing required headers") }
  end

  test "creates users without passwords" do
    importer = ApplicantImporter.new(@valid_csv)
    importer.import

    alice = User.find_by(email: "alice@example.com")
    assert_nil alice.password_digest
  end

  test "handles boolean values correctly" do
    importer = ApplicantImporter.new(@valid_csv)
    importer.import

    alice = User.find_by(email: "alice@example.com")
    assert alice.demographic_underrepresented_group
    assert_equal true, alice.questionnaire_responses["currently_writing_ruby"]

    bob = User.find_by(email: "bob@example.com")
    assert_not bob.demographic_underrepresented_group
    assert_equal false, bob.questionnaire_responses["currently_writing_ruby"]
  end

  test "parses years as integers" do
    importer = ApplicantImporter.new(@valid_csv)
    importer.import

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

    importer = ApplicantImporter.new(csv_with_missing)
    result = importer.import

    assert result.success?
    charlie = User.find_by(email: "charlie@example.com")
    assert_nil charlie.demographic_year_of_birth
    assert_nil charlie.demographic_year_started_programming
    assert_nil charlie.demographic_year_started_ruby
  end

  test "maps location data correctly" do
    importer = ApplicantImporter.new(@valid_csv)
    importer.import

    alice = User.find_by(email: "alice@example.com")
    assert_equal "Portland, OR", alice.questionnaire_responses["location"]
    # The geocoding should extract city and country_code
    # This would normally be done by the geocoder gem
  end
end

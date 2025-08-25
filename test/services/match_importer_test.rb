require "test_helper"
require "csv"

class MatchImporterTest < ActiveSupport::TestCase
  setup do
    # Create existing users
    @mentor1 = User.create!(
      email: "mentor1@example.com",
      first_name: "Mentor",
      last_name: "One",
      skip_password_validation: true,
      available_as_mentor_at: 1.month.ago
    )

    @mentor2 = User.create!(
      email: "mentor2@example.com",
      first_name: "Mentor",
      last_name: "Two",
      skip_password_validation: true,
      available_as_mentor_at: 1.month.ago
    )

    @applicant1 = User.create!(
      email: "applicant1@example.com",
      first_name: "Applicant",
      last_name: "One",
      skip_password_validation: true,
      requested_mentorship_at: 1.month.ago
    )

    @applicant2 = User.create!(
      email: "applicant2@example.com",
      first_name: "Applicant",
      last_name: "Two",
      skip_password_validation: true,
      requested_mentorship_at: 1.month.ago
    )

    @valid_csv = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["applicant1@example.com", "USA", "Portland", "mentor1@example.com"]
      csv << ["applicant2@example.com", "Canada", "Toronto", "mentor2@example.com"]
    end

    @reassignment_csv = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["applicant1@example.com", "USA", "Portland", "mentor1@example.com"]
      csv << ["applicant1@example.com", "USA", "Portland", "mentor2@example.com"] # Reassignment
    end

    @orphaned_match_csv = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["nonexistent@example.com", "USA", "Portland", "mentor1@example.com"]
      csv << ["applicant1@example.com", "USA", "Portland", "nonexistent@example.com"]
    end
  end

  test "imports matches successfully" do
    importer = MatchImporter.new(@valid_csv)

    assert_difference "Mentorship.count", 2 do
      result = importer.import
      assert result.success?
      assert_equal 2, result.imported_count
    end

    mentorship1 = Mentorship.find_by(mentor: @mentor1, applicant: @applicant1)
    assert_not_nil mentorship1
    assert_equal "active", mentorship1.standing

    mentorship2 = Mentorship.find_by(mentor: @mentor2, applicant: @applicant2)
    assert_not_nil mentorship2
    assert_equal "active", mentorship2.standing
  end

  test "handles match reassignments by voiding previous match" do
    importer = MatchImporter.new(@reassignment_csv)

    assert_difference "Mentorship.count", 2 do
      result = importer.import
      # First row creates a match, second row ends first and creates new
      assert_equal 2, result.imported_count
    end

    # First match should be ended
    old_mentorship = Mentorship.find_by(mentor: @mentor1, applicant: @applicant1)
    assert_equal "ended", old_mentorship.standing

    # New match should be active
    new_mentorship = Mentorship.find_by(mentor: @mentor2, applicant: @applicant1)
    assert_equal "active", new_mentorship.standing
  end

  test "reports orphaned matches" do
    importer = MatchImporter.new(@orphaned_match_csv)
    result = importer.import

    assert_not result.success?
    assert_equal 0, result.imported_count
    assert_equal 2, result.failed_count

    assert result.row_errors.any? { |e| e[:error].include?("Applicant not found: nonexistent@example.com") }
    assert result.row_errors.any? { |e| e[:error].include?("Mentor not found: nonexistent@example.com") }
  end

  test "validates required headers" do
    invalid_csv = CSV.generate do |csv|
      csv << ["Email", "Mentor"]
      csv << ["test@example.com", "mentor@example.com"]
    end

    importer = MatchImporter.new(invalid_csv)
    result = importer.import

    assert_not result.success?
    assert result.errors.any? { |e| e.include?("Missing required headers") }
  end

  test "prevents duplicate active matches" do
    # Create an existing active match
    Mentorship.create!(
      mentor: @mentor1,
      applicant: @applicant1,
      standing: "active"
    )

    importer = MatchImporter.new(@valid_csv)
    result = importer.import

    # Should skip the duplicate and import the second one
    assert_equal 1, result.imported_count
    assert_equal 1, result.failed_count
    assert result.row_errors.any? { |e| e[:error].include?("already has an active mentorship") }
  end

  test "updates applicant location from match data" do
    csv_with_location = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["applicant1@example.com", "US", "Seattle", "mentor1@example.com"]
    end

    importer = MatchImporter.new(csv_with_location)
    importer.import

    @applicant1.reload
    assert_equal "Seattle", @applicant1.city
    assert_equal "US", @applicant1.country_code
  end

  test "handles case-insensitive email matching" do
    csv_with_mixed_case = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["APPLICANT1@EXAMPLE.COM", "USA", "Portland", "MENTOR1@EXAMPLE.COM"]
    end

    importer = MatchImporter.new(csv_with_mixed_case)

    assert_difference "Mentorship.count", 1 do
      result = importer.import
      assert result.success?
    end

    mentorship = Mentorship.find_by(mentor: @mentor1, applicant: @applicant1)
    assert_not_nil mentorship
  end

  test "uses transaction for rollback on failure" do
    csv_with_error = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["applicant1@example.com", "USA", "Portland", "mentor1@example.com"]
      csv << ["nonexistent@example.com", "USA", "Portland", "mentor2@example.com"] # Will fail
    end

    importer = MatchImporter.new(csv_with_error, use_transaction: true)

    assert_no_difference "Mentorship.count" do
      result = importer.import
      assert_not result.success?
    end
  end
end

require "test_helper"
require "csv"

class ImportJobTest < ActiveJob::TestCase
  setup do
    @mentor_csv = CSV.generate do |csv|
      csv << ["Date", "What's your name?", "What's your email?", "Where do you work?",
        "Year you started programming in Ruby", "Country", "City", "Twitter?", "Github?",
        "Do you have a personal site?", "Worked anywhere else?", "Why are you doing this?",
        "Have you done any mentoring before?", "Are you a member of the WNB.rb community? (https://wnb-rb.dev)",
        "Do you have a strong preference to mentor someone from a particular demographic?",
        "How would you describe yourself?"]
      csv << ["2023-01-15", "John Doe", "john@example.com", "https://acme.com",
        "2015", "US", "San Francisco", "@johndoe", "johndoe",
        "https://johndoe.com", "Previous Corp", "I want to help!",
        "Yes", "No", "Junior developers", "Senior developer"]
    end

    @applicant_csv = CSV.generate do |csv|
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
        "Marketing", "Career guidance and code reviews",
        "Yes", "", "woman"]
    end

    @match_csv = CSV.generate do |csv|
      csv << ["Applicant Email", "Applicant Country", "Applicant City", "Mentor Email"]
      csv << ["alice@example.com", "USA", "Portland", "john@example.com"]
    end
  end

  test "imports mentor CSV successfully" do
    assert_enqueued_with(job: ImportJob) do
      ImportJob.perform_later("mentor", @mentor_csv)
    end

    perform_enqueued_jobs

    assert User.exists?(email: "john@example.com")
    mentor = User.find_by(email: "john@example.com")
    assert_equal "John", mentor.first_name
    assert mentor.available_as_mentor_at.present?
  end

  test "imports applicant CSV successfully" do
    assert_enqueued_with(job: ImportJob) do
      ImportJob.perform_later("applicant", @applicant_csv)
    end

    perform_enqueued_jobs

    assert User.exists?(email: "alice@example.com")
    applicant = User.find_by(email: "alice@example.com")
    assert_equal "Alice", applicant.first_name
    assert applicant.requested_mentorship_at.present?
  end

  test "imports match CSV successfully" do
    # Create users first
    ImportJob.perform_now("mentor", @mentor_csv)
    ImportJob.perform_now("applicant", @applicant_csv)

    assert_enqueued_with(job: ImportJob) do
      ImportJob.perform_later("match", @match_csv)
    end

    perform_enqueued_jobs

    mentor = User.find_by(email: "john@example.com")
    applicant = User.find_by(email: "alice@example.com")

    assert Mentorship.exists?(mentor: mentor, applicant: applicant, standing: "active")
  end

  test "creates import report on success" do
    ImportJob.perform_now("mentor", @mentor_csv, report_id: "test_report_123")

    report = ImportReport.find_by(report_id: "test_report_123")
    assert_not_nil report
    assert_equal "mentor", report.import_type
    assert_equal "completed", report.status
    assert_equal 1, report.imported_count
    assert_equal 0, report.failed_count
  end

  test "creates import report on failure" do
    invalid_csv = "invalid,csv,data\nno,headers"

    ImportJob.perform_now("mentor", invalid_csv, report_id: "test_report_456")

    report = ImportReport.find_by(report_id: "test_report_456")
    assert_not_nil report
    assert_equal "failed", report.status
    assert report.import_errors.any?
  end

  test "handles unknown import type" do
    # Should fail during the report creation due to validation
    assert_raises(ActiveRecord::RecordInvalid) do
      ImportJob.perform_now("unknown", @mentor_csv)
    end
  end
end

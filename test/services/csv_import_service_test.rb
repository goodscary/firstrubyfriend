require "test_helper"
require "csv"

class CsvImportServiceTest < ActiveSupport::TestCase
  class TestImporter < CsvImportService
    def process_row(row, index)
      {success: true, data: row}
    end

    def required_headers
      ["name", "email"]
    end
  end

  setup do
    @valid_csv = CSV.generate do |csv|
      csv << ["name", "email", "extra"]
      csv << ["John Doe", "john@example.com", "data"]
      csv << ["Jane Smith", "jane@example.com", "info"]
    end

    @invalid_headers_csv = CSV.generate do |csv|
      csv << ["wrong", "headers"]
      csv << ["data", "here"]
    end

    @malformed_csv = "not,a,valid\ncsv\"file"
  end

  test "imports valid CSV successfully" do
    service = TestImporter.new(@valid_csv)
    result = service.import

    assert result.success?
    assert_equal 2, result.imported_count
    assert_equal 0, result.failed_count
    assert_empty result.errors
  end

  test "validates required headers" do
    service = TestImporter.new(@invalid_headers_csv)
    result = service.import

    assert_not result.success?
    assert_includes result.errors, "Missing required headers: name, email"
  end

  test "handles malformed CSV" do
    service = TestImporter.new(@malformed_csv)
    result = service.import

    assert_not result.success?
    assert_match(/CSV parsing error/, result.errors.first)
  end

  test "rolls back on failure when using transaction" do
    csv_with_error = CSV.generate do |csv|
      csv << ["name", "email"]
      csv << ["Valid", "valid@example.com"]
      csv << ["", ""] # This will cause validation to fail
    end

    service = TestImporter.new(csv_with_error, use_transaction: true)

    # Override process_row to fail on empty data
    service.define_singleton_method(:process_row) do |row, index|
      if row["name"].blank? || row["email"].blank?
        raise ActiveRecord::RecordInvalid.new(User.new)
      end
      {success: true, data: row}
    end

    assert_no_difference "User.count" do
      result = service.import
      assert_not result.success?
    end
  end

  test "tracks row-level errors" do
    service = TestImporter.new(@valid_csv)

    # Override to fail on second row
    service.define_singleton_method(:process_row) do |row, index|
      if index == 1
        {success: false, error: "Failed to process Jane"}
      else
        {success: true, data: row}
      end
    end

    result = service.import
    assert_not result.success?
    assert_equal 1, result.imported_count
    assert_equal 1, result.failed_count
    assert_equal 1, result.row_errors.size
    assert_equal 3, result.row_errors.first[:row]
    assert_equal "Failed to process Jane", result.row_errors.first[:error]
  end

  test "provides detailed import summary" do
    service = TestImporter.new(@valid_csv)
    result = service.import

    assert result.summary.present?
    assert_includes result.summary, "Total rows: 2"
    assert_includes result.summary, "Successfully imported: 2"
    assert_includes result.summary, "Failed: 0"
  end
end

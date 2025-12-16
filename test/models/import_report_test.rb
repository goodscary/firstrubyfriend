require "test_helper"

class ImportReportTest < ActiveSupport::TestCase
  test "processing? returns true for processing status" do
    report = ImportReport.new(status: "processing")
    assert report.processing?
  end

  test "processing? returns false for completed status" do
    report = ImportReport.new(status: "completed")
    assert_not report.processing?
  end

  test "processing? returns false for failed status" do
    report = ImportReport.new(status: "failed")
    assert_not report.processing?
  end

  test "completed? returns true only for completed status" do
    assert ImportReport.new(status: "completed").completed?
    assert_not ImportReport.new(status: "failed").completed?
    assert_not ImportReport.new(status: "processing").completed?
  end

  test "failed? returns true only for failed status" do
    assert ImportReport.new(status: "failed").failed?
    assert_not ImportReport.new(status: "completed").failed?
    assert_not ImportReport.new(status: "processing").failed?
  end
end

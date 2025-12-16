require "test_helper"

class Admin::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users.mentor
    sign_in_as(@user)
  end

  test "unauthenticated user cannot access imports" do
    delete session_path(Session.last)
    get new_admin_import_path
    assert_redirected_to sign_in_path
  end

  test "can view new import form" do
    get new_admin_import_path
    assert_response :success
    assert_select "input[type=file]"
    assert_select "input[type=radio][value=mentor]"
    assert_select "input[type=radio][value=applicant]"
    assert_select "input[type=radio][value=match]"
  end

  test "can upload CSV and start import" do
    csv_content = "first name,last name,email\nJane,Doe,jane@example.com"
    file = Rack::Test::UploadedFile.new(
      StringIO.new(csv_content),
      "text/csv",
      original_filename: "mentors.csv"
    )

    assert_enqueued_with(job: ImportJob) do
      post admin_imports_path, params: {import_type: "mentor", file: file}
    end

    assert_redirected_to %r{/admin/imports/mentor-\d+}
    assert_equal "Import started", flash[:notice]
  end

  test "rejects missing file" do
    post admin_imports_path, params: {import_type: "mentor"}
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /select a file/i
  end

  test "rejects non-CSV files" do
    file = Rack::Test::UploadedFile.new(
      StringIO.new("not csv content"),
      "text/plain",
      original_filename: "data.txt"
    )

    post admin_imports_path, params: {import_type: "mentor", file: file}
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /must be a CSV/i
  end

  test "rejects invalid import type" do
    file = Rack::Test::UploadedFile.new(
      StringIO.new("data"),
      "text/csv",
      original_filename: "data.csv"
    )

    post admin_imports_path, params: {import_type: "invalid", file: file}
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /invalid import type/i
  end

  test "can view import status" do
    report = ImportReport.create!(
      report_id: "mentor-123",
      import_type: "mentor",
      status: "completed",
      imported_count: 10,
      failed_count: 2
    )

    get admin_import_path(report.report_id)
    assert_response :success
    assert_select "p.text-2xl", text: "10"
    assert_select "p.text-2xl", text: "2"
  end

  test "can view processing import with spinner" do
    report = ImportReport.create!(
      report_id: "mentor-456",
      import_type: "mentor",
      status: "processing"
    )

    get admin_import_path(report.report_id)
    assert_response :success
    assert_select "svg.animate-spin"
    assert_select "meta[http-equiv=refresh]"
  end

  test "can view import history" do
    3.times do |i|
      ImportReport.create!(
        report_id: "mentor-#{i}",
        import_type: "mentor",
        status: "completed"
      )
    end

    get admin_imports_path
    assert_response :success
    assert_select "tbody tr", minimum: 3
  end

  test "import history shows empty state" do
    ImportReport.delete_all

    get admin_imports_path
    assert_response :success
    assert_select "p.text-gray-500", /no imports yet/i
  end
end

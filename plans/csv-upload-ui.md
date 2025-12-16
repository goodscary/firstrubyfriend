# feat: CSV Upload UI for Historical Data Imports

## Overview

Add a web UI to upload CSV files for importing historical mentors, applicants, and matches. The app already has a robust CSV import system via rake tasks—this feature exposes it through an admin interface.

## Problem Statement

Currently, historical data imports require:
1. SSH access to the server
2. Running rake tasks manually (`rake imports:mentors[file.csv]`)
3. Technical knowledge of the import process

This creates friction for non-technical admins who need to import historical mentorship data.

## Proposed Solution

Create a simple admin interface at `/admin/imports` that:
1. Allows file upload with import type selection
2. Shows import progress and status
3. Displays results with error details
4. Lists recent import history

### Design Philosophy

Keep it simple. The backend import system is already well-designed—we just need a thin UI layer on top. No Active Storage (read file directly), no WebSockets (use Turbo Frame refresh), minimal JavaScript.

## Acceptance Criteria

### Functional Requirements

- [ ] Admin can upload a CSV file and select import type (mentor/applicant/match)
- [ ] System validates file is present and has .csv extension
- [ ] Import processes asynchronously via existing ImportJob
- [ ] Admin sees status page with spinner while processing
- [ ] Admin sees summary when complete (imported count, failed count)
- [ ] Admin can view row-level errors for failed imports
- [ ] Admin can see list of recent imports with status badges
- [ ] Non-admin users cannot access import interface

### Non-Functional Requirements

- [ ] File validation happens before job enqueue (fast feedback)
- [ ] Status page auto-refreshes while processing
- [ ] UI follows existing Tailwind patterns from pending_matches
- [ ] Tests cover upload, validation, status display, and access control

## MVP

### User Model Update

```ruby
# app/models/user.rb (add to existing)
def admin?
  admin_emails = ENV.fetch("ADMIN_EMAILS", "").split(",").map(&:strip)
  admin_emails.include?(email)
end
```

Set in environment:
```bash
# .env or production environment
ADMIN_EMAILS=admin@example.com,other@example.com
```

### ImportReport Model Updates

```ruby
# app/models/import_report.rb (add these methods)
def processing?
  status.in?(%w[pending processing])
end

def completed?
  status == "completed"
end

def failed?
  status == "failed"
end
```

### Routes

```ruby
# config/routes.rb (add to admin namespace)
namespace :admin do
  resources :imports, only: [:index, :new, :create, :show]
  # ... existing routes
end
```

### Controller

```ruby
# app/controllers/admin/imports_controller.rb
module Admin
  class ImportsController < ApplicationController
    before_action :require_admin

    def index
      @reports = ImportReport.recent
    end

    def new
    end

    def create
      file = params[:file]

      if file.blank?
        flash.now[:alert] = "Please select a file"
        return render :new, status: :unprocessable_entity
      end

      unless file.original_filename.end_with?(".csv")
        flash.now[:alert] = "File must be a CSV"
        return render :new, status: :unprocessable_entity
      end

      unless %w[mentor applicant match].include?(params[:import_type])
        flash.now[:alert] = "Invalid import type"
        return render :new, status: :unprocessable_entity
      end

      report_id = "#{params[:import_type]}-#{Time.current.to_i}"
      ImportJob.perform_later(params[:import_type], file.read, report_id: report_id)

      redirect_to admin_import_path(report_id), notice: "Import started"
    end

    def show
      @report = ImportReport.find_by!(report_id: params[:id])
    end

    private

    def require_admin
      redirect_to root_path, alert: "Not authorized" unless Current.session&.user&.admin?
    end
  end
end
```

### Views

```erb
<%# app/views/admin/imports/new.html.erb %>
<div class="mx-auto max-w-2xl">
  <h1 class="text-2xl font-bold mb-6">Import Data</h1>

  <div class="bg-amber-50 border border-amber-200 rounded-md p-4 mb-6">
    <p class="text-sm text-amber-800">
      <strong>Import order matters:</strong> Import mentors first, then applicants, then matches.
      Match imports require existing mentor and applicant emails.
    </p>
  </div>

  <%= form_with url: admin_imports_path, method: :post, multipart: true, class: "space-y-6" do |f| %>
    <% if flash[:alert] %>
      <div class="bg-red-50 border border-red-200 rounded-md p-4">
        <p class="text-sm text-red-800"><%= flash[:alert] %></p>
      </div>
    <% end %>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Import Type</label>
      <div class="space-y-2">
        <label class="flex items-center">
          <%= radio_button_tag :import_type, "mentor", true, class: "mr-2" %>
          <span>Mentors</span>
        </label>
        <label class="flex items-center">
          <%= radio_button_tag :import_type, "applicant", false, class: "mr-2" %>
          <span>Applicants</span>
        </label>
        <label class="flex items-center">
          <%= radio_button_tag :import_type, "match", false, class: "mr-2" %>
          <span>Matches</span>
        </label>
      </div>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">CSV File</label>
      <%= file_field_tag :file, accept: ".csv",
          class: "block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4
                  file:rounded-md file:border-0 file:text-sm file:font-semibold
                  file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100" %>
    </div>

    <div>
      <%= submit_tag "Start Import",
          class: "bg-indigo-600 hover:bg-indigo-500 text-white rounded-md px-4 py-2
                  text-sm font-semibold shadow-sm" %>
    </div>
  <% end %>

  <div class="mt-8 border-t pt-6">
    <%= link_to "View Import History", admin_imports_path,
        class: "text-indigo-600 hover:text-indigo-500 text-sm font-medium" %>
  </div>
</div>
```

```erb
<%# app/views/admin/imports/show.html.erb %>
<div class="mx-auto max-w-2xl">
  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-bold">Import Status</h1>
    <%= link_to "Back to Imports", admin_imports_path,
        class: "text-indigo-600 hover:text-indigo-500 text-sm" %>
  </div>

  <%= turbo_frame_tag "import_status", src: @report.processing? ? admin_import_path(@report.report_id) : nil do %>
    <div class="bg-white shadow rounded-lg p-6">
      <dl class="grid grid-cols-2 gap-4 mb-6">
        <div>
          <dt class="text-sm font-medium text-gray-500">Type</dt>
          <dd class="text-sm text-gray-900 capitalize"><%= @report.import_type %></dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Status</dt>
          <dd><%= import_status_badge(@report) %></dd>
        </div>
        <div>
          <dt class="text-sm font-medium text-gray-500">Started</dt>
          <dd class="text-sm text-gray-900"><%= time_ago_in_words(@report.created_at) %> ago</dd>
        </div>
        <% if @report.duration %>
          <div>
            <dt class="text-sm font-medium text-gray-500">Duration</dt>
            <dd class="text-sm text-gray-900"><%= @report.duration.round(1) %>s</dd>
          </div>
        <% end %>
      </dl>

      <% if @report.processing? %>
        <div class="flex items-center justify-center py-8">
          <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
          </svg>
          <span class="ml-3 text-gray-600">Processing import...</span>
        </div>
      <% else %>
        <div class="border-t pt-4">
          <h3 class="font-medium mb-3">Results</h3>
          <div class="grid grid-cols-2 gap-4">
            <div class="bg-green-50 rounded-md p-4">
              <p class="text-2xl font-bold text-green-700"><%= @report.imported_count || 0 %></p>
              <p class="text-sm text-green-600">Imported</p>
            </div>
            <div class="bg-red-50 rounded-md p-4">
              <p class="text-2xl font-bold text-red-700"><%= @report.failed_count || 0 %></p>
              <p class="text-sm text-red-600">Failed</p>
            </div>
          </div>
        </div>

        <% if @report.row_errors.present? %>
          <div class="border-t pt-4 mt-4">
            <h3 class="font-medium mb-3">Row Errors</h3>
            <div class="bg-gray-50 rounded-md p-4 max-h-64 overflow-y-auto">
              <ul class="space-y-2 text-sm">
                <% @report.row_errors.each do |error| %>
                  <li>
                    <span class="font-medium">Row <%= error["row"] %>:</span>
                    <span class="text-red-600"><%= error["error"] %></span>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        <% end %>

        <% if @report.error_messages.present? %>
          <div class="border-t pt-4 mt-4">
            <h3 class="font-medium mb-3">Import Errors</h3>
            <div class="bg-red-50 rounded-md p-4">
              <ul class="list-disc list-inside text-sm text-red-700">
                <% @report.error_messages.each do |error| %>
                  <li><%= error %></li>
                <% end %>
              </ul>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
  <% end %>
</div>
```

```erb
<%# app/views/admin/imports/index.html.erb %>
<div class="mx-auto max-w-4xl">
  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-bold">Import History</h1>
    <%= link_to "New Import", new_admin_import_path,
        class: "bg-indigo-600 hover:bg-indigo-500 text-white rounded-md px-4 py-2
                text-sm font-semibold shadow-sm" %>
  </div>

  <% if @reports.empty? %>
    <p class="text-gray-500 text-center py-12">No imports yet</p>
  <% else %>
    <div class="bg-white shadow rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Results</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
            <th class="px-6 py-3"></th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <% @reports.each do |report| %>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 capitalize">
                <%= report.import_type %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <%= import_status_badge(report) %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <% if report.completed? || report.failed? %>
                  <span class="text-green-600"><%= report.imported_count || 0 %></span> /
                  <span class="text-red-600"><%= report.failed_count || 0 %></span>
                <% else %>
                  —
                <% end %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <%= time_ago_in_words(report.created_at) %> ago
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right">
                <%= link_to "View", admin_import_path(report.report_id),
                    class: "text-indigo-600 hover:text-indigo-500 text-sm font-medium" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  <% end %>
</div>
```

### Helper

```ruby
# app/helpers/admin/imports_helper.rb
module Admin::ImportsHelper
  def import_status_badge(report)
    classes = case report.status
    when "pending", "processing"
      "bg-yellow-100 text-yellow-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "failed"
      "bg-red-100 text-red-800"
    end

    content_tag :span, report.status.capitalize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end
end
```

### Tests

```ruby
# test/controllers/admin/imports_controller_test.rb
require "test_helper"

class Admin::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:mentor_one)
    ENV["ADMIN_EMAILS"] = @admin.email
    sign_in_as(@admin)
  end

  teardown do
    ENV.delete("ADMIN_EMAILS")
  end

  test "non-admin cannot access imports" do
    sign_in_as(users(:applicant_one))
    get new_admin_import_path
    assert_redirected_to root_path
  end

  test "admin can view new import form" do
    get new_admin_import_path
    assert_response :success
    assert_select "input[type=file]"
  end

  test "admin can upload CSV and start import" do
    csv = Rack::Test::UploadedFile.new(
      StringIO.new("first name,last name,email\nJane,Doe,jane@example.com"),
      "text/csv",
      original_filename: "mentors.csv"
    )

    assert_enqueued_with(job: ImportJob) do
      post admin_imports_path, params: { import_type: "mentor", file: csv }
    end

    assert_redirected_to %r{/admin/imports/mentor-}
  end

  test "rejects missing file" do
    post admin_imports_path, params: { import_type: "mentor" }
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /select a file/
  end

  test "rejects non-CSV files" do
    txt = Rack::Test::UploadedFile.new(
      StringIO.new("not csv"),
      "text/plain",
      original_filename: "data.txt"
    )

    post admin_imports_path, params: { import_type: "mentor", file: txt }
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /must be a CSV/
  end

  test "rejects invalid import type" do
    csv = Rack::Test::UploadedFile.new(
      StringIO.new("data"),
      "text/csv",
      original_filename: "data.csv"
    )

    post admin_imports_path, params: { import_type: "invalid", file: csv }
    assert_response :unprocessable_entity
  end

  test "admin can view import status" do
    report = ImportReport.create!(
      report_id: "mentor-123",
      import_type: "mentor",
      status: "completed",
      imported_count: 10,
      failed_count: 2
    )

    get admin_import_path(report.report_id)
    assert_response :success
  end

  test "admin can view import history" do
    3.times do |i|
      ImportReport.create!(
        report_id: "mentor-#{i}",
        import_type: "mentor",
        status: "completed"
      )
    end

    get admin_imports_path
    assert_response :success
    assert_select "tbody tr", count: 3
  end
end
```

```ruby
# test/models/import_report_test.rb (add these tests)
test "processing? returns true for pending status" do
  report = ImportReport.new(status: "pending")
  assert report.processing?
end

test "processing? returns true for processing status" do
  report = ImportReport.new(status: "processing")
  assert report.processing?
end

test "processing? returns false for completed status" do
  report = ImportReport.new(status: "completed")
  assert_not report.processing?
end

test "completed? returns true only for completed status" do
  assert ImportReport.new(status: "completed").completed?
  assert_not ImportReport.new(status: "failed").completed?
end

test "failed? returns true only for failed status" do
  assert ImportReport.new(status: "failed").failed?
  assert_not ImportReport.new(status: "completed").failed?
end
```

## Key Design Decisions

### No Duplicate ImportReport Creation

The existing `ImportJob` already creates the `ImportReport` (line 8-13 in `app/jobs/import_job.rb`). The controller does NOT create one—it just passes a `report_id` string and redirects to that ID. This avoids creating duplicate records.

### Turbo Frame Polling (No Custom Stimulus)

Instead of writing a custom Stimulus polling controller, we use Turbo Frame's built-in behavior:

```erb
<%= turbo_frame_tag "import_status", src: @report.processing? ? admin_import_path(@report.report_id) : nil do %>
```

When `src` is present, Turbo Frame automatically lazy-loads (and can be configured to refresh). The `src` is only set when processing, so completed imports don't poll.

For auto-refresh, add to `show.html.erb`:
```erb
<% if @report.processing? %>
  <meta name="turbo-refresh-method" content="morph">
  <meta name="turbo-refresh-scroll" content="preserve">
  <%= tag.meta name: "turbo-visit-control", content: "reload" %>
  <script>setTimeout(() => location.reload(), 3000)</script>
<% end %>
```

Or use the simpler `meta refresh`:
```erb
<% if @report.processing? %>
  <meta http-equiv="refresh" content="3">
<% end %>
```

### ENV-Based Admin Check

Using `ENV["ADMIN_EMAILS"]` instead of Rails credentials:
- Easier to test (just set ENV in setup)
- Follows Twelve-Factor App principles
- No need to stub credentials

### Module Namespacing

Using `module Admin` instead of `class Admin::ImportsController`:
```ruby
module Admin
  class ImportsController < ApplicationController
```

This follows Rails conventions and avoids autoloading issues.

### Helper for Status Badge

Status badge rendering is extracted to a helper to avoid duplication between `index` and `show` views.

## Dependencies

- `ENV["ADMIN_EMAILS"]` must be set with comma-separated admin emails
- Add `processing?`, `completed?`, `failed?` methods to ImportReport model
- Create helper module `Admin::ImportsHelper`

## Success Metrics

1. Admins can import CSVs without SSH access
2. Import errors are clearly visible
3. No unauthorized access to import feature

## References

### Internal
- Import job: `app/jobs/import_job.rb`
- Import report: `app/models/import_report.rb`
- Import concern: `app/models/concerns/csv_importable.rb`
- Admin UI pattern: `app/views/admin/pending_matches/index.html.erb`

### External
- [Rails Form Helpers - File Uploads](https://guides.rubyonrails.org/form_helpers.html#uploading-files)
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)

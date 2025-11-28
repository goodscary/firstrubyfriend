module Admin
  class ImportsController < ApplicationController
    def index
      @import_reports = ImportReport.recent.limit(50)
    end

    def show
      @import_report = ImportReport.find_by!(report_id: params[:id])
    end

    def new
    end

    def create
      unless params[:file].present?
        redirect_to new_admin_import_path, alert: "Please select a CSV file to import."
        return
      end

      unless params[:import_type].present?
        redirect_to new_admin_import_path, alert: "Please select an import type."
        return
      end

      csv_content = params[:file].read
      import_type = params[:import_type]
      report_id = "import_#{import_type}_#{Time.current.to_i}"

      report = ImportReport.create!(
        report_id: report_id,
        import_type: import_type,
        status: "processing",
        started_at: Time.current
      )

      begin
        importer = build_importer(import_type, csv_content)
        result = importer.import

        report.update!(
          status: result.success? ? "completed" : "failed",
          imported_count: result.imported_count,
          failed_count: result.failed_count,
          error_messages: result.errors,
          row_errors: result.row_errors,
          completed_at: Time.current
        )

        if result.success?
          redirect_to admin_import_path(report.report_id),
            notice: "Import completed successfully. Imported #{result.imported_count} records."
        else
          redirect_to admin_import_path(report.report_id),
            alert: "Import completed with errors. #{result.imported_count} imported, #{result.failed_count} failed."
        end
      rescue => e
        report.update!(
          status: "failed",
          error_messages: [e.message],
          completed_at: Time.current
        )
        redirect_to admin_import_path(report.report_id),
          alert: "Import failed: #{e.message}"
      end
    end

    private

    def build_importer(import_type, csv_content)
      case import_type
      when "mentor"
        MentorImporter.new(csv_content)
      when "applicant"
        ApplicantImporter.new(csv_content)
      when "match"
        MatchImporter.new(csv_content)
      else
        raise ArgumentError, "Unknown import type: #{import_type}"
      end
    end
  end
end

class ImportJob < ApplicationJob
  queue_as :default

  def perform(import_type, csv_content, options = {})
    report_id = options[:report_id] || SecureRandom.hex(8)

    # Create import report
    report = ImportReport.create!(
      report_id: report_id,
      import_type: import_type,
      status: "processing",
      started_at: Time.current
    )

    begin
      use_transaction = options[:use_transaction] || false

      # Perform import using model class methods
      result = case import_type
      when "mentor"
        User.import_mentors_from_csv(csv_content, use_transaction: use_transaction)
      when "applicant"
        User.import_applicants_from_csv(csv_content, use_transaction: use_transaction)
      when "match"
        Mentorship.import_matches_from_csv(csv_content, use_transaction: use_transaction)
      else
        raise ArgumentError, "Unknown import type: #{import_type}"
      end

      # Update report with results
      report.update!(
        status: result.success? ? "completed" : "failed",
        imported_count: result.imported_count,
        failed_count: result.failed_count,
        error_messages: result.errors,
        row_errors: result.row_errors,
        completed_at: Time.current
      )

      # Backfill email dates if this was a match import
      if import_type == "match" && result.success?
        backfill_result = Mentorship.backfill_email_dates

        report.update!(
          metadata: {
            backfilled_mentorships: backfill_result.processed_count
          }
        )
      end

      report
    rescue => e
      report.update!(
        status: "failed",
        error_messages: [e.message],
        completed_at: Time.current
      )

      raise e
    end
  end
end

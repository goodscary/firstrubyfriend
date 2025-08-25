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
      # Select appropriate importer
      importer = case import_type
      when "mentor"
        MentorImporter.new(csv_content, options)
      when "applicant"
        ApplicantImporter.new(csv_content, options)
      when "match"
        MatchImporter.new(csv_content, options)
      else
        raise ArgumentError, "Unknown import type: #{import_type}"
      end

      # Perform import
      result = importer.import

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
        backfiller = EmailDateBackfiller.new
        backfill_result = backfiller.backfill_all

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

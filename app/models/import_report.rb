class ImportReport < ApplicationRecord
  validates :report_id, presence: true, uniqueness: true
  validates :import_type, presence: true, inclusion: {in: %w[mentor applicant match]}

  enum :status, %w[processing completed failed].index_by(&:itself)

  serialize :error_messages, coder: JSON
  serialize :row_errors, coder: JSON
  serialize :metadata, coder: JSON

  after_initialize do
    self.error_messages ||= []
    self.row_errors ||= []
    self.metadata ||= {}
  end

  def import_errors
    error_messages
  end

  # Don't override the built-in errors method
  # def errors
  #   error_messages
  # end

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def summary
    lines = []
    lines << "Import Report: #{report_id}"
    lines << "Type: #{import_type.capitalize}"
    lines << "Status: #{status.capitalize}"

    if completed_at
      lines << "Duration: #{duration&.round(2)} seconds"
      lines << "Imported: #{imported_count || 0}"
      lines << "Failed: #{failed_count || 0}"
    end

    if import_errors.present? && import_errors.any?
      lines << "\nGeneral Errors:"
      import_errors.first(5).each { |error| lines << "  - #{error}" }
      if import_errors.size > 5
        lines << "  ... and #{import_errors.size - 5} more errors"
      end
    end

    if row_errors.present? && row_errors.any?
      lines << "\nRow Errors:"
      row_errors.first(5).each do |error|
        lines << "  Row #{error["row"]}: #{error["error"]}"
      end
      if row_errors.size > 5
        lines << "  ... and #{row_errors.size - 5} more row errors"
      end
    end

    if metadata.present? && metadata["backfilled_mentorships"]
      lines << "\nBackfilled email dates for #{metadata["backfilled_mentorships"]} mentorships"
    end

    lines.join("\n")
  end
end

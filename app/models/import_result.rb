class ImportResult
  attr_reader :imported_count, :failed_count, :errors, :row_errors

  def initialize
    @imported_count = 0
    @failed_count = 0
    @errors = []
    @row_errors = []
  end

  def success?
    errors.empty? && row_errors.empty?
  end

  def increment_imported
    @imported_count += 1
  end

  def increment_failed
    @failed_count += 1
  end

  def add_error(message)
    @errors << message
  end

  def add_row_error(row_number, message)
    @row_errors << {row: row_number, error: message}
    increment_failed
  end

  def summary
    lines = []
    lines << "Import Summary:"
    lines << "Total rows: #{imported_count + failed_count}"
    lines << "Successfully imported: #{imported_count}"
    lines << "Failed: #{failed_count}"

    if errors.any?
      lines << "\nGeneral Errors:"
      errors.each { |error| lines << "  - #{error}" }
    end

    if row_errors.any?
      lines << "\nRow Errors:"
      row_errors.first(10).each do |error|
        lines << "  Row #{error[:row]}: #{error[:error]}"
      end
      if row_errors.size > 10
        lines << "  ... and #{row_errors.size - 10} more errors"
      end
    end

    lines.join("\n")
  end

  def to_h
    {
      success: success?,
      imported_count: imported_count,
      failed_count: failed_count,
      errors: errors,
      row_errors: row_errors,
      summary: summary
    }
  end
end

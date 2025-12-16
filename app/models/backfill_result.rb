class BackfillResult
  attr_reader :processed_count, :errors
  attr_accessor :audit_trail

  def initialize
    @processed_count = 0
    @errors = []
    @audit_trail = nil
  end

  def success?
    errors.empty?
  end

  def increment_processed
    @processed_count += 1
  end

  def add_error(message)
    @errors << message
  end

  def summary
    lines = []
    lines << "Backfill Summary:"
    lines << "Mentorships processed: #{processed_count}"

    if audit_trail && audit_trail.any?
      lines << "Total backfilled entries: #{audit_trail.sum { |e| e[:backfilled_fields].size }}"
    end

    if errors.any?
      lines << "\nErrors:"
      errors.first(10).each { |error| lines << "  - #{error}" }
      if errors.size > 10
        lines << "  ... and #{errors.size - 10} more errors"
      end
    end

    lines.join("\n")
  end
end

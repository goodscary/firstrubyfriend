class EmailDateBackfiller
  attr_reader :options, :audit_trail

  def initialize(options = {})
    @options = options
    @audit_trail = [] if options[:audit]
  end

  def backfill_all
    result = BackfillResult.new

    Mentorship.find_each do |mentorship|
      backfill_result = backfill_mentorship(mentorship)

      if backfill_result[:success]
        result.increment_processed

        if options[:audit] && backfill_result[:backfilled_count] > 0
          audit_trail << {
            mentorship_id: mentorship.id,
            backfilled_fields: backfill_result[:backfilled_fields],
            created_at: mentorship.created_at
          }
        end
      else
        result.add_error("Failed to backfill mentorship #{mentorship.id}: #{backfill_result[:error]}")
      end
    end

    result.audit_trail = audit_trail if options[:audit]
    result
  end

  def backfill_mentorship(mentorship)
    backfilled_fields = []
    backfilled_count = 0

    # Calculate how many months have elapsed since creation
    months_elapsed = ((Time.current - mentorship.created_at) / 1.month).floor

    # Cap at 6 months (the maximum email sequence)
    months_to_backfill = [months_elapsed, 6].min

    # Backfill for each elapsed month
    (1..months_to_backfill).each do |month_number|
      # Calculate theoretical send date (month_number months after creation)
      theoretical_send_date = mentorship.created_at + month_number.months

      # Backfill applicant email
      applicant_field = "applicant_month_#{month_number}_email_sent_at"
      if mentorship.send(applicant_field).nil?
        mentorship.send("#{applicant_field}=", theoretical_send_date)
        backfilled_fields << applicant_field
        backfilled_count += 1
      end

      # Backfill mentor email
      mentor_field = "mentor_month_#{month_number}_email_sent_at"
      if mentorship.send(mentor_field).nil?
        mentorship.send("#{mentor_field}=", theoretical_send_date)
        backfilled_fields << mentor_field
        backfilled_count += 1
      end
    end

    # Save if any changes were made
    if backfilled_count > 0
      if mentorship.save
        {success: true, backfilled_count: backfilled_count, backfilled_fields: backfilled_fields}
      else
        {success: false, error: mentorship.errors.full_messages.join(", ")}
      end
    else
      {success: true, backfilled_count: 0, backfilled_fields: []}
    end
  rescue => e
    {success: false, error: e.message}
  end
end

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

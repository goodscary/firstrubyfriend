class Mentorship < ApplicationRecord
  include AutoMatching
  include CsvImportable

  has_prefix_id :mnt

  belongs_to :mentor, class_name: "User"
  belongs_to :applicant, class_name: "User"

  enum :standing, %w[pending active ended rejected].index_by(&:itself)

  scope :pending, -> { where(standing: :pending) }
  scope :active, -> { where(standing: :active) }
  scope :active_or_pending, -> { where(standing: [:pending, :active]) }

  validates :standing, presence: true
  validate :mentor_and_applicant_cannot_be_same

  MATCH_CSV_HEADERS = {
    "applicant" => :applicant_email,
    "country" => :applicant_country,
    "city" => :applicant_city,
    "mentor" => :mentor_email,
    "gone" => :gone_status
  }.freeze

  def self.find_matches_for_applicant(applicant)
    MentorshipMatcher.new(applicant).matches
  end

  def self.import_matches_from_csv(csv_content, use_transaction: false)
    import_from_csv(csv_content, use_transaction: use_transaction)
  end

  def self.csv_import_required_headers
    # Gone is optional
    MATCH_CSV_HEADERS.keys - ["gone"]
  end

  def self.process_csv_row(row, index)
    mapped_data = map_csv_row(row, MATCH_CSV_HEADERS)

    applicant = User.find_by("LOWER(email) = ?", mapped_data[:applicant_email]&.downcase)
    unless applicant
      return {success: false, error: "Applicant not found: #{mapped_data[:applicant_email]}"}
    end

    mentor = User.find_by("LOWER(email) = ?", mapped_data[:mentor_email]&.downcase)
    unless mentor
      return {success: false, error: "Mentor not found: #{mapped_data[:mentor_email]}"}
    end

    if mapped_data[:applicant_city].present?
      applicant.city = mapped_data[:applicant_city]
    end
    if mapped_data[:applicant_country].present?
      applicant.country_code = normalize_country_code(mapped_data[:applicant_country])
    end
    applicant.save! if applicant.changed?

    # Determine standing based on "Gone" column
    is_gone = mapped_data[:gone_status].present? && mapped_data[:gone_status].strip.downcase != ""
    desired_standing = is_gone ? "ended" : "active"

    existing_mentorship = find_by(applicant: applicant, mentor: mentor)

    if existing_mentorship
      # Update standing if different
      if existing_mentorship.standing != desired_standing
        existing_mentorship.update!(standing: desired_standing)
        return {success: true, data: existing_mentorship, updated: true}
      else
        return {success: false, error: "Mentorship already exists between #{applicant.email} and #{mentor.email} with standing: #{existing_mentorship.standing}"}
      end
    end

    # End any other active mentorship for this applicant
    other_active = find_by(applicant: applicant, standing: "active")
    other_active&.update!(standing: "ended")

    mentorship = new(
      mentor: mentor,
      applicant: applicant,
      standing: desired_standing
    )

    if mentorship.save
      {success: true, data: mentorship}
    else
      {success: false, error: "Failed to create mentorship: #{mentorship.errors.full_messages.join(", ")}"}
    end
  rescue => e
    {success: false, error: "Error processing row: #{e.message}"}
  end

  def self.normalize_country_code(country)
    case country.downcase
    when "usa", "us", "united states" then "US"
    when "canada", "ca" then "CA"
    when "uk", "united kingdom", "gb" then "GB"
    when "mexico", "mx" then "MX"
    else
      if country.length == 2
        country.upcase
      else
        country[0..1].upcase
      end
    end
  end

  def self.backfill_email_dates(audit: false)
    result = BackfillResult.new
    audit_trail = [] if audit

    find_each do |mentorship|
      backfill_result = mentorship.backfill_email_dates_for_mentorship

      if backfill_result[:success]
        result.increment_processed

        if audit && backfill_result[:backfilled_count] > 0
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

    result.audit_trail = audit_trail if audit
    result
  end

  def backfill_email_dates_for_mentorship
    backfilled_fields = []
    backfilled_count = 0

    months_elapsed = ((Time.current - created_at) / 1.month).floor
    months_to_backfill = [months_elapsed, 6].min

    (1..months_to_backfill).each do |month_number|
      theoretical_send_date = created_at + month_number.months

      applicant_field = "applicant_month_#{month_number}_email_sent_at"
      if send(applicant_field).nil?
        send("#{applicant_field}=", theoretical_send_date)
        backfilled_fields << applicant_field
        backfilled_count += 1
      end

      mentor_field = "mentor_month_#{month_number}_email_sent_at"
      if send(mentor_field).nil?
        send("#{mentor_field}=", theoretical_send_date)
        backfilled_fields << mentor_field
        backfilled_count += 1
      end
    end

    if backfilled_count > 0
      if save
        {success: true, backfilled_count: backfilled_count, backfilled_fields: backfilled_fields}
      else
        {success: false, error: errors.full_messages.join(", ")}
      end
    else
      {success: true, backfilled_count: 0, backfilled_fields: []}
    end
  rescue => e
    {success: false, error: e.message}
  end

  private

  def mentor_and_applicant_cannot_be_same
    errors.add(:mentor, "cannot be the same as applicant") if mentor == applicant
  end
end

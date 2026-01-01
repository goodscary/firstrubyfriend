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
    "mentor" => :mentor_email
  }.freeze

  def self.find_matches_for_applicant(applicant)
    MentorshipMatcher.new(applicant).matches
  end

  def self.import_matches_from_csv(csv_content, match_date:)
    @match_date = match_date
    import_from_csv(csv_content)
  ensure
    @match_date = nil
  end

  def self.csv_import_required_headers
    MATCH_CSV_HEADERS.keys
  end

  def self.process_csv_row(row, index)
    mapped_data = {}
    MATCH_CSV_HEADERS.each { |csv_header, field| mapped_data[field] = row[csv_header]&.strip }

    applicant = User.find_by("LOWER(email) = ?", mapped_data[:applicant_email]&.downcase)
    unless applicant
      return {success: false, error: "Applicant not found: #{mapped_data[:applicant_email]}"}
    end

    mentor = User.find_by("LOWER(email) = ?", mapped_data[:mentor_email]&.downcase)
    unless mentor
      return {success: false, error: "Mentor not found: #{mapped_data[:mentor_email]}"}
    end

    existing_mentorship = find_by(applicant: applicant, mentor: mentor)
    if existing_mentorship
      return {success: false, error: "Mentorship already exists between #{applicant.email} and #{mentor.email}"}
    end

    # End any other active mentorship for this applicant
    other_active = find_by(applicant: applicant, standing: "active")
    other_active&.update!(standing: "ended")

    mentorship = new(
      mentor: mentor,
      applicant: applicant,
      standing: "active",
      created_at: @match_date
    )

    if mentorship.save
      {success: true, data: mentorship}
    else
      {success: false, error: "Failed to create mentorship: #{mentorship.errors.full_messages.join(", ")}"}
    end
  rescue => e
    {success: false, error: "Error processing row: #{e.message}"}
  end

  def self.backfill_email_dates
    processed = 0
    errors = 0

    find_each do |mentorship|
      result = mentorship.backfill_email_dates_for_mentorship
      if result[:success]
        processed += 1
      else
        errors += 1
        Rails.logger.info "[Backfill] Mentorship #{mentorship.id}: #{result[:error]}"
      end
    end

    Rails.logger.info "[Backfill] Complete: #{processed} processed, #{errors} errors"
    errors == 0
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

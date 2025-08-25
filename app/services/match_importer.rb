class MatchImporter < CsvImportService
  HEADER_MAPPING = {
    "applicant email" => :applicant_email,
    "applicant country" => :applicant_country,
    "applicant city" => :applicant_city,
    "mentor email" => :mentor_email
  }

  def required_headers
    HEADER_MAPPING.keys
  end

  protected

  def process_row(row, index)
    mapped_data = map_row_data(row)

    # Find applicant
    applicant = User.find_by("LOWER(email) = ?", mapped_data[:applicant_email]&.downcase)
    unless applicant
      return {success: false, error: "Applicant not found: #{mapped_data[:applicant_email]}"}
    end

    # Find mentor
    mentor = User.find_by("LOWER(email) = ?", mapped_data[:mentor_email]&.downcase)
    unless mentor
      return {success: false, error: "Mentor not found: #{mapped_data[:mentor_email]}"}
    end

    # Update applicant location if provided
    if mapped_data[:applicant_city].present?
      applicant.city = mapped_data[:applicant_city]
    end
    if mapped_data[:applicant_country].present?
      applicant.country_code = normalize_country_code(mapped_data[:applicant_country])
    end
    applicant.save! if applicant.changed?

    # Check for existing active mentorship for this applicant
    existing_mentorship = Mentorship.find_by(applicant: applicant, standing: "active")

    if existing_mentorship
      if existing_mentorship.mentor_id == mentor.id
        # Same mentor, skip
        return {success: false, error: "Applicant #{applicant.email} already has an active mentorship with #{mentor.email}"}
      else
        # Different mentor - void the old mentorship (reassignment)
        existing_mentorship.update!(standing: "ended")
      end
    end

    # Create new mentorship
    mentorship = Mentorship.new(
      mentor: mentor,
      applicant: applicant,
      standing: "active"
    )

    if mentorship.save
      {success: true, data: mentorship}
    else
      {success: false, error: "Failed to create mentorship: #{mentorship.errors.full_messages.join(", ")}"}
    end
  rescue => e
    {success: false, error: "Error processing row: #{e.message}"}
  end

  private

  def map_row_data(row)
    mapped = {}
    HEADER_MAPPING.each do |csv_header, field_name|
      mapped[field_name] = row[csv_header]&.strip
    end
    mapped
  end

  def normalize_country_code(country)
    case country.downcase
    when "usa", "us", "united states" then "US"
    when "canada", "ca" then "CA"
    when "uk", "united kingdom", "gb" then "GB"
    when "mexico", "mx" then "MX"
    else
      # If it's already a 2-letter code, use it
      if country.length == 2
        country.upcase
      else
        # Default to first 2 letters uppercase
        country[0..1].upcase
      end
    end
  end
end

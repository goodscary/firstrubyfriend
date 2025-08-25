class MentorImporter < CsvImportService
  HEADER_MAPPING = {
    "date" => :import_date,
    "first name" => :first_name,
    "last name" => :last_name,
    "email" => :email,
    "what company do you work for or what do you do?" => :company,
    "where do you work?" => :work_location,
    "location (where do you currently live?)" => :location,
    "previous location" => :previous_location,
    "confirmed location" => :confirmed_location,
    "links" => :links,
    "who would you prefer to mentor" => :mentee_preference,
    "how many people would you prefer to mentor simultaneously?" => :max_mentees,
    "languages you feel comfortable mentoring in" => :languages
  }

  def required_headers
    HEADER_MAPPING.keys
  end

  protected

  def process_row(row, index)
    mapped_data = map_row_data(row)

    # Validate email
    unless valid_email?(mapped_data[:email])
      return {success: false, error: "Invalid email format: #{mapped_data[:email]}"}
    end

    # Find or create user
    user = User.find_or_initialize_by(email: mapped_data[:email].downcase)

    # Update user attributes
    user.first_name = mapped_data[:first_name]
    user.last_name = mapped_data[:last_name]
    user.skip_password_validation = true if user.new_record?

    # Build questionnaire responses
    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_questionnaire_responses(mapped_data))

    # Validate required fields
    if user.first_name.blank? || user.last_name.blank?
      return {success: false, error: "Missing required name fields for #{mapped_data[:email]}"}
    end

    if user.save
      # Mark as available as mentor
      user.update!(available_as_mentor_at: parse_date(mapped_data[:import_date]) || Time.current)

      {success: true, data: user}
    else
      {success: false, error: "Failed to save user: #{user.errors.full_messages.join(", ")}"}
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

  def build_questionnaire_responses(data)
    responses = {}

    responses["company"] = data[:company] if data[:company].present?
    responses["work_location"] = data[:work_location] if data[:work_location].present?
    responses["location"] = data[:confirmed_location].presence || data[:location]
    responses["previous_location"] = data[:previous_location] if data[:previous_location].present?
    responses["links"] = data[:links] if data[:links].present?
    responses["mentee_preference"] = data[:mentee_preference] if data[:mentee_preference].present?

    # Parse max mentees as integer
    if data[:max_mentees].present?
      responses["max_mentees"] = data[:max_mentees].to_i
    end

    # Parse languages as array
    if data[:languages].present?
      responses["languages"] = data[:languages].split(",").map(&:strip)
    end

    responses
  end

  def valid_email?(email)
    return false if email.blank?
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end
end

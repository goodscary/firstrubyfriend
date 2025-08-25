class ApplicantImporter < CsvImportService
  HEADER_MAPPING = {
    "date" => :import_date,
    "first name" => :first_name,
    "last name" => :last_name,
    "email" => :email,
    "what year were you born?" => :year_of_birth,
    "what year did you first start programming?" => :year_started_programming,
    "what year did you first start using ruby?" => :year_started_ruby,
    "do you self-identify as a member of an underrepresented group in tech?" => :underrepresented_group,
    "if you feel comfortable, please share which group(s) you identify with" => :underrepresented_details,
    "what is your current level of ruby experience?" => :ruby_experience,
    "where do you currently live? (city, country)" => :location,
    "are you currently writing ruby regularly?" => :currently_writing_ruby,
    "how did you get started with programming in general?" => :how_started,
    "what do you want to get out of being mentored?" => :mentorship_goals,
    "any links you'd like to share?" => :links
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

    # Set demographic fields
    user.demographic_year_of_birth = parse_year(mapped_data[:year_of_birth])
    user.demographic_year_started_programming = parse_year(mapped_data[:year_started_programming])
    user.demographic_year_started_ruby = parse_year(mapped_data[:year_started_ruby])
    user.demographic_underrepresented_group = parse_boolean(mapped_data[:underrepresented_group])
    user.demographic_underrepresented_group_details = mapped_data[:underrepresented_details] if mapped_data[:underrepresented_details].present?

    # Build questionnaire responses
    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_questionnaire_responses(mapped_data))

    # Extract location data
    if mapped_data[:location].present?
      user.questionnaire_responses["location"] = mapped_data[:location]
      # Parse city and country from location string
      parse_location(user, mapped_data[:location])
    end

    # Validate required fields
    if user.first_name.blank? || user.last_name.blank?
      return {success: false, error: "Missing required name fields for #{mapped_data[:email]}"}
    end

    if user.save
      # Mark as requesting mentorship
      user.update!(requested_mentorship_at: parse_date(mapped_data[:import_date]) || Time.current)

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

    responses["ruby_experience"] = data[:ruby_experience] if data[:ruby_experience].present?
    responses["currently_writing_ruby"] = parse_boolean(data[:currently_writing_ruby])
    responses["how_started"] = data[:how_started] if data[:how_started].present?
    responses["mentorship_goals"] = data[:mentorship_goals] if data[:mentorship_goals].present?
    responses["links"] = data[:links] if data[:links].present?

    responses
  end

  def parse_boolean(value)
    return nil if value.blank?
    value.downcase == "yes" || value.downcase == "true"
  end

  def parse_year(value)
    return nil if value.blank?
    year = value.to_i
    (year > 0) ? year : nil
  end

  def parse_location(user, location_string)
    # Simple parsing - in production this would use geocoder
    parts = location_string.split(",").map(&:strip)
    if parts.size >= 2
      user.city = parts[0]
      # Map common country names to codes
      country = parts.last
      user.country_code = case country.downcase
      when "usa", "us", "united states" then "US"
      when "canada", "ca" then "CA"
      when "uk", "united kingdom" then "GB"
      else
        # For states like "OR", "TX", assume US
        if country.length == 2 && country.match?(/^[A-Z]{2}$/)
          user.city = "#{parts[0]}, #{country}"
          "US"
        else
          country[0..1].upcase
        end
      end
    end
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

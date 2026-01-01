class User < ApplicationRecord
  include Matchable
  include CsvImportable
  extend ActiveJob::Performs

  has_prefix_id :usr

  performs :subscribe_to_mailcoach

  attr_accessor :skip_password_validation

  has_secure_password validations: false

  serialize :questionnaire_responses, coder: JSON

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :mentorship_roles_as_mentor, class_name: "Mentorship", foreign_key: "mentor_id"
  has_many :mentorship_roles_as_applicant, class_name: "Mentorship", foreign_key: "applicant_id"
  has_many :mentors, through: :mentorship_roles_as_mentor
  has_many :applicants, through: :mentorship_roles_as_applicant
  has_one :mentor_questionnaire, foreign_key: "respondent_id"
  has_one :applicant_questionnaire, foreign_key: "respondent_id"
  has_many :user_languages
  has_many :languages, through: :user_languages

  def active_applicant = mentorship_roles_as_applicant.active.first

  def active_mentor = mentorship_roles_as_mentor.active.first

  def active_mentorship = active_mentor || active_applicant

  accepts_nested_attributes_for :user_languages

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, allow_nil: true, length: {minimum: 12}, unless: :skip_password_validation
  validates :password, not_pwned: {message: "might easily be guessed"}, unless: :skip_password_validation
  validates :lat, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, allow_nil: true
  validates :lng, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, allow_nil: true

  enum :unsubscribed_reason, %w[ghosted_mentor ghosted_applicant requested_removal].index_by(&:itself)

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_update if: :email_previously_changed? do
    events.create! action: "email_verification_requested"
  end

  after_update if: :password_digest_previously_changed? do
    events.create! action: "password_changed"
  end

  after_update if: [:verified_previously_changed?, :verified?] do
    events.create! action: "email_verified"
  end

  after_create_commit :subscribe_to_mailcoach_later

  geocoded_by :address, latitude: :lat, longitude: :lng

  after_validation :geocode, if: ->(obj) { obj.city_changed? || obj.country_code_changed? }

  scope :all_mentors, -> {
    includes(:languages, :mentor_questionnaire)
      .joins(:mentor_questionnaire)
  }

  scope :all_applicants, -> {
    includes(:languages, :applicant_questionnaire)
      .joins(:applicant_questionnaire)
  }

  scope :available_mentors, -> {
    includes(:languages, :mentor_questionnaire)
      .joins(:mentor_questionnaire)
      .where.not(available_as_mentor_at: nil)
      .where.not(id: Mentorship.active_or_pending.select(:mentor_id))
  }

  scope :unmatched_applicants, -> {
    includes(:languages, :applicant_questionnaire)
      .joins(:applicant_questionnaire)
      .where.not(id: Mentorship.active_or_pending.select(:applicant_id))
  }

  APPLICANT_CSV_HEADERS = {
    "date" => :import_date,
    "what's your name?" => :name,
    "what's your email?" => :email,
    "country" => :country,
    "city" => :city,
    "are you working anywhere yet?" => :current_employer,
    "are you writing ruby there?" => :currently_writing_ruby,
    "where'd you get your start?" => :how_started,
    "would you consider yourself in an underrepresented group?" => :underrepresented_group,
    "twitter?" => :twitter_handle,
    "github?" => :github_handle,
    "do you have a personal site?" => :personal_site,
    "any languages other than english?" => :languages,
    "what did you do before you became a programmer?" => :previous_career,
    "what are you looking to get out of the mentoring?" => :mentorship_goals,
    "are you a member of the wnb.rb community? (https://wnb-rb.dev)" => :wnb_member,
    "do you have a strong preference to mentor someone from a particular demographic?" => :demographic_preference,
    "how would you describe yourself?" => :self_description
  }.freeze

  MENTOR_CSV_HEADERS = {
    "date" => :import_date,
    "what's your name?" => :name,
    "what's your email?" => :email,
    "where do you work?" => :company,
    "year you started programming in ruby" => :year_started_ruby,
    "country" => :country,
    "city" => :city,
    "twitter?" => :twitter_handle,
    "github?" => :github_handle,
    "do you have a personal site?" => :personal_site,
    "worked anywhere else?" => :previous_workplaces,
    "why are you doing this?" => :mentoring_reason,
    "have you done any mentoring before?" => :has_mentored_before,
    "are you a member of the wnb.rb community? (https://wnb-rb.dev)" => :wnb_member,
    "do you have a strong preference to mentor someone from a particular demographic?" => :demographic_preference,
    "how would you describe yourself?" => :self_description
  }.freeze

  def self.import_applicants_from_csv(csv_content, use_transaction: false, rate_limit_delay: 1)
    @current_import_type = :applicant
    import_from_csv(csv_content, use_transaction: use_transaction, rate_limit_delay: rate_limit_delay)
  ensure
    @current_import_type = nil
  end

  def self.import_mentors_from_csv(csv_content, use_transaction: false, rate_limit_delay: 1)
    @current_import_type = :mentor
    import_from_csv(csv_content, use_transaction: use_transaction, rate_limit_delay: rate_limit_delay)
  ensure
    @current_import_type = nil
  end

  def self.csv_import_required_headers
    case @current_import_type
    when :applicant then APPLICANT_CSV_HEADERS.keys
    when :mentor then MENTOR_CSV_HEADERS.keys
    else []
    end
  end

  def self.process_csv_row(row, index)
    case @current_import_type
    when :applicant then process_applicant_row(row)
    when :mentor then process_mentor_row(row)
    else {success: false, error: "Unknown import type"}
    end
  end

  def self.process_applicant_row(row)
    mapped_data = map_csv_row(row, APPLICANT_CSV_HEADERS)

    unless valid_import_email?(mapped_data[:email])
      return {success: false, error: "Invalid email format: #{mapped_data[:email]}"}
    end

    user = find_or_initialize_by(email: mapped_data[:email].downcase)

    # Parse name - split on first space for first/last name
    if mapped_data[:name].present?
      name_parts = mapped_data[:name].strip.split(/\s+/, 2)
      user.first_name = name_parts[0]
      user.last_name = name_parts[1] || ""
    end

    user.skip_password_validation = true if user.new_record?

    # Set location fields
    user.city = mapped_data[:city] if mapped_data[:city].present?
    user.country_code = parse_country_code(mapped_data[:country]) if mapped_data[:country].present?
    user.demographic_underrepresented_group = parse_import_boolean(mapped_data[:underrepresented_group])

    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_applicant_questionnaire_responses(mapped_data))

    if user.first_name.blank?
      return {success: false, error: "Missing required name for #{mapped_data[:email]}"}
    end

    if user.save
      user.update!(requested_mentorship_at: parse_import_date(mapped_data[:import_date]) || Time.current)
      {success: true, data: user}
    else
      {success: false, error: "Failed to save user: #{user.errors.full_messages.join(", ")}"}
    end
  rescue => e
    {success: false, error: "Error processing row: #{e.message}"}
  end

  def self.process_mentor_row(row)
    mapped_data = map_csv_row(row, MENTOR_CSV_HEADERS)

    unless valid_import_email?(mapped_data[:email])
      return {success: false, error: "Invalid email format: #{mapped_data[:email]}"}
    end

    user = find_or_initialize_by(email: mapped_data[:email].downcase)

    # Parse name - split on first space for first/last name
    if mapped_data[:name].present?
      name_parts = mapped_data[:name].strip.split(/\s+/, 2)
      user.first_name = name_parts[0]
      user.last_name = name_parts[1] || ""
    end

    user.skip_password_validation = true if user.new_record?

    # Set location fields
    user.city = mapped_data[:city] if mapped_data[:city].present?
    user.country_code = parse_country_code(mapped_data[:country]) if mapped_data[:country].present?
    user.demographic_year_started_ruby = parse_import_year(mapped_data[:year_started_ruby])

    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_mentor_questionnaire_responses(mapped_data))

    if user.first_name.blank?
      return {success: false, error: "Missing required name for #{mapped_data[:email]}"}
    end

    if user.save
      user.update!(available_as_mentor_at: parse_import_date(mapped_data[:import_date]) || Time.current)
      {success: true, data: user}
    else
      {success: false, error: "Failed to save user: #{user.errors.full_messages.join(", ")}"}
    end
  rescue => e
    {success: false, error: "Error processing row: #{e.message}"}
  end

  def self.build_applicant_questionnaire_responses(data)
    responses = {}
    responses["current_employer"] = data[:current_employer] if data[:current_employer].present?
    responses["currently_writing_ruby"] = parse_import_boolean(data[:currently_writing_ruby])
    responses["how_started"] = data[:how_started] if data[:how_started].present?
    responses["twitter_handle"] = data[:twitter_handle] if data[:twitter_handle].present?
    responses["github_handle"] = data[:github_handle] if data[:github_handle].present?
    responses["personal_site"] = data[:personal_site] if data[:personal_site].present?
    responses["languages"] = data[:languages] if data[:languages].present?
    responses["previous_career"] = data[:previous_career] if data[:previous_career].present?
    responses["mentorship_goals"] = data[:mentorship_goals] if data[:mentorship_goals].present?
    responses["wnb_member"] = parse_import_boolean(data[:wnb_member])
    responses["demographic_preference"] = data[:demographic_preference] if data[:demographic_preference].present?
    responses["self_description"] = data[:self_description] if data[:self_description].present?
    responses
  end

  def self.build_mentor_questionnaire_responses(data)
    responses = {}
    responses["company"] = data[:company] if data[:company].present?
    responses["twitter_handle"] = data[:twitter_handle] if data[:twitter_handle].present?
    responses["github_handle"] = data[:github_handle] if data[:github_handle].present?
    responses["personal_site"] = data[:personal_site] if data[:personal_site].present?
    responses["previous_workplaces"] = data[:previous_workplaces] if data[:previous_workplaces].present?
    responses["mentoring_reason"] = data[:mentoring_reason] if data[:mentoring_reason].present?
    responses["has_mentored_before"] = parse_import_boolean(data[:has_mentored_before])
    responses["wnb_member"] = parse_import_boolean(data[:wnb_member])
    responses["demographic_preference"] = data[:demographic_preference] if data[:demographic_preference].present?
    responses["self_description"] = data[:self_description] if data[:self_description].present?
    responses
  end

  def self.valid_import_email?(email)
    return false if email.blank?
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def self.parse_import_boolean(value)
    return nil if value.blank?
    value.downcase == "yes" || value.downcase == "true"
  end

  def self.parse_import_year(value)
    return nil if value.blank?
    year = value.to_i
    (year > 0) ? year : nil
  end

  def self.parse_import_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end

  def self.parse_country_code(country)
    return nil if country.blank?
    case country.downcase.strip
    when "usa", "us", "united states", "united states of america" then "US"
    when "canada", "ca" then "CA"
    when "uk", "united kingdom", "great britain", "gb", "england", "scotland", "wales" then "GB"
    when "australia", "au" then "AU"
    when "germany", "de" then "DE"
    when "france", "fr" then "FR"
    when "netherlands", "nl" then "NL"
    when "spain", "es" then "ES"
    when "italy", "it" then "IT"
    when "japan", "jp" then "JP"
    when "india", "in" then "IN"
    when "brazil", "br" then "BR"
    else
      country.strip.upcase[0..1]
    end
  end

  def self.parse_import_location(user, location_string)
    parts = location_string.split(",").map(&:strip)
    if parts.size >= 2
      user.city = parts[0]
      country = parts.last
      user.country_code = case country.downcase
      when "usa", "us", "united states" then "US"
      when "canada", "ca" then "CA"
      when "uk", "united kingdom" then "GB"
      else
        if country.length == 2 && country.match?(/^[A-Z]{2}$/)
          user.city = "#{parts[0]}, #{country}"
          "US"
        else
          country[0..1].upcase
        end
      end
    end
  end

  def address
    [city, country_code].compact.join(", ")
  end

  def mentor?
    available_as_mentor_at.present? || mentorship_roles_as_mentor.exists?
  end

  def applicant?
    requested_mentorship_at.present? || mentorship_roles_as_applicant.exists?
  end

  def subscribe_to_mailcoach
    MailcoachClient.new.add(email)
  rescue MailcoachClient::MissingCredentials
    Rails.logger.warn "Mailcoach credentials not configured, skipping subscription for #{email}"
  rescue MailcoachClient::Error => e
    Rails.logger.error "Failed to subscribe #{email} to Mailcoach: #{e.message}"
  end
end

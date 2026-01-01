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
  }.freeze

  MENTOR_CSV_HEADERS = {
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
    user.first_name = mapped_data[:first_name]
    user.last_name = mapped_data[:last_name]
    user.skip_password_validation = true if user.new_record?

    user.demographic_year_of_birth = parse_import_year(mapped_data[:year_of_birth])
    user.demographic_year_started_programming = parse_import_year(mapped_data[:year_started_programming])
    user.demographic_year_started_ruby = parse_import_year(mapped_data[:year_started_ruby])
    user.demographic_underrepresented_group = parse_import_boolean(mapped_data[:underrepresented_group])
    user.demographic_underrepresented_group_details = mapped_data[:underrepresented_details] if mapped_data[:underrepresented_details].present?

    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_applicant_questionnaire_responses(mapped_data))

    if mapped_data[:location].present?
      user.questionnaire_responses["location"] = mapped_data[:location]
      parse_import_location(user, mapped_data[:location])
    end

    if user.first_name.blank? || user.last_name.blank?
      return {success: false, error: "Missing required name fields for #{mapped_data[:email]}"}
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
    user.first_name = mapped_data[:first_name]
    user.last_name = mapped_data[:last_name]
    user.skip_password_validation = true if user.new_record?

    user.questionnaire_responses ||= {}
    user.questionnaire_responses.merge!(build_mentor_questionnaire_responses(mapped_data))

    if user.first_name.blank? || user.last_name.blank?
      return {success: false, error: "Missing required name fields for #{mapped_data[:email]}"}
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
    responses["ruby_experience"] = data[:ruby_experience] if data[:ruby_experience].present?
    responses["currently_writing_ruby"] = parse_import_boolean(data[:currently_writing_ruby])
    responses["how_started"] = data[:how_started] if data[:how_started].present?
    responses["mentorship_goals"] = data[:mentorship_goals] if data[:mentorship_goals].present?
    responses["links"] = data[:links] if data[:links].present?
    responses
  end

  def self.build_mentor_questionnaire_responses(data)
    responses = {}
    responses["company"] = data[:company] if data[:company].present?
    responses["work_location"] = data[:work_location] if data[:work_location].present?
    responses["location"] = data[:confirmed_location].presence || data[:location]
    responses["previous_location"] = data[:previous_location] if data[:previous_location].present?
    responses["links"] = data[:links] if data[:links].present?
    responses["mentee_preference"] = data[:mentee_preference] if data[:mentee_preference].present?
    responses["max_mentees"] = data[:max_mentees].to_i if data[:max_mentees].present?
    responses["languages"] = data[:languages].split(",").map(&:strip) if data[:languages].present?
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

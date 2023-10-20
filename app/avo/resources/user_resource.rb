class UserResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :email, as: :text
  field :verified, as: :boolean
  field :unsubscribed_at, as: :date_time
  field :unsubscribed_reason, as: :select, enum: ::User.unsubscribed_reasons
  field :available_as_mentor_at, as: :date_time
  field :requested_mentorship_at, as: :date_time
  field :city, as: :text
  field :country_code, as: :text
  field :lat, as: :number
  field :lng, as: :number
  field :demographic_year_of_birth, as: :number
  field :demographic_year_started_ruby, as: :number
  field :demographic_year_started_programming, as: :number
  field :demographic_underrepresented_group, as: :boolean
  # field :email_verification_tokens, as: :has_many
  # field :password_reset_tokens, as: :has_many
  field :mentorship_roles_as_mentor, as: :has_many
  field :mentorship_roles_as_applicant, as: :has_many
  field :mentors, as: :has_many, through: :mentorship_roles_as_mentor
  field :applicants, as: :has_many, through: :mentorship_roles_as_applicant
  # field :mentor_questionnaire, as: :has_one
  # add fields here
end

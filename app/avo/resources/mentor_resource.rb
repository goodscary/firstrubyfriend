class MentorResource < Avo::BaseResource
  self.title = :email
  self.includes = []
  self.model_class = "User"
  # self.resolve_query_scope = ->(model_class:) {
  #   puts ["model_class->", model_class].inspect
  #   model_class.joins(:mentorship_roles_as_applicant).where(mentorship_roles_as_applicant: nil)
  # }
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :email, as: :text
end

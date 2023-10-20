class ApplicantResource < Avo::BaseResource
  self.title = :email
  self.includes = []
  self.model_class = "User"
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :email, as: :text
end

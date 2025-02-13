class ApplicantsController < ApplicationController
  before_action :verify_admin, only: [:index]

  def index
    @applicants = User.all_applicants
  end

  private

  def verify_admin
    redirect_to root_path, alert: "You are not authorized to access this page" if !Current.user.admin?
  end
end

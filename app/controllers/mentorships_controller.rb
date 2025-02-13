class MentorshipsController < ApplicationController
  before_action :verify_admin, only: [:index]

  def index
    @mentorships = Mentorship.all
  end

  def new
  end

  private

  def verify_admin
    redirect_to root_path, alert: "You are not authorized to access this page" if !Current.user.admin?
  end
end

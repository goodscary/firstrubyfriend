class ApplicantsController < ApplicationController
  def index
    @applicants = User.all_applicants
  end
end

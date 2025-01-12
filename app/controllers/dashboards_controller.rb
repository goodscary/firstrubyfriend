class DashboardsController < ApplicationController
  def show
    @mentor_questionnaire = Current.user.mentor_questionnaire
    @applicant_questionnaire = Current.user.applicant_questionnaire
  end
end

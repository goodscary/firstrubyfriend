class DashboardsController < ApplicationController
  def show
    @mentor_questionnaire = Current.user.mentor_questionnaire
    @mentee_questionnaire = Current.user.mentee_questionnaire
  end
end

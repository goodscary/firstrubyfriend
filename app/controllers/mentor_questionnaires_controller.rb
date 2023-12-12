class MentorQuestionnairesController < ApplicationController
  def new
    @mentor_questionnaire = MentorQuestionnaire.new
    @mentor_questionnaire.build_respondent
  end

  def create
    @mentor_questionnaire = MentorQuestionnaire.new(mentor_questionnaire_params)
    @mentor_questionnaire.respondent = Current.user
    if @mentor_questionnaire.save
      redirect_to root_path, notice: "Mentor questionnaire was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def mentor_questionnaire_params
    params.require(:mentor_questionnaire).permit(
      :name,
      :company_url,
      :twitter_handle,
      :github_handle,
      :personal_site_url,
      :previous_workplaces,
      :has_mentored_before,
      :mentoring_reason,
      :has_mentored_before,
      :mentoring_reason,
      :preferred_style_career,
      :preferred_style_code,
      respondent_attributes: [
        :respondent_id,
        :demographic_year_started_ruby
      ]
    )
  end
end

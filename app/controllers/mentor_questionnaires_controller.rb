class MentorQuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_mentor_questionnaire, only: [:edit, :update]

  def new
    if @user.mentor_questionnaire.present?
      redirect_to edit_mentor_questionnaire_path(@user.mentor_questionnaire)
    else
      @mentor_questionnaire = MentorQuestionnaire.new
      @user.user_languages.build
    end
  end

  def create
    @mentor_questionnaire = @user.build_mentor_questionnaire(mentor_questionnaire_params)

    if @mentor_questionnaire.save
      @user.update(user_params)
      redirect_to root_path, notice: "Your Mentor Questionnaire answers have been saved"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = @mentor_questionnaire.respondent
  end

  def update
    if @mentor_questionnaire.update(mentor_questionnaire_params)
      update_user_if_needed
      redirect_to root_path, notice: "Your Mentor Questionnaire has been updated."
    else
      render :edit, status: :unprocessable_entity
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
      :preferred_style_career,
      :preferred_style_code
    )
  end

  def user_params
    params.require(:user).permit(
      :city,
      :country_code,
      :demographic_year_started_ruby,
      user_languages_attributes: [:language_id, :id, :_destroy]
    )
  end

  def set_user
    @user = Current.user
  end

  def set_mentor_questionnaire
    @mentor_questionnaire = @user.mentor_questionnaire
  end

  def update_user_if_needed
    if user_params.present? && @user.attributes.slice(*user_params.keys) != user_params
      @user.update(user_params)
    end
  end
end

class MenteeQuestionnairesController < ApplicationController
  before_action :set_user
  before_action :set_mentee_questionnaire, only: [:edit, :update]

  def new
    if @user.mentee_questionnaire.present?
      redirect_to edit_mentee_questionnaire_path(@user.mentee_questionnaire)
    else
      @mentee_questionnaire = MenteeQuestionnaire.new
      @user.user_languages.build
    end
  end

  def create
    @mentee_questionnaire = @user.build_mentee_questionnaire(mentee_questionnaire_params)

    if @mentee_questionnaire.save
      @user.update(user_params)
      redirect_to root_path, notice: "Your Mentee Questionnaire answers have been saved"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = @mentee_questionnaire.respondent
  end

  def update
    if @mentee_questionnaire.update(mentee_questionnaire_params)
      update_user_if_needed
      redirect_to root_path, notice: "Your Mentee Questionnaire has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def mentee_questionnaire_params
    params.require(:mentee_questionnaire).permit(
      :name,
      :work_url,
      :currently_writing_ruby,
      :where_started_coding,
      :twitter_handle,
      :github_handle,
      :personal_site_url,
      :previous_job,
      :mentorship_goals,
      :wnbrb_member,
      :self_description,
      :looking_for_career_mentorship,
      :looking_for_code_mentorship
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

  def set_mentee_questionnaire
    @mentee_questionnaire = @user.mentee_questionnaire
  end

  def update_user_if_needed
    if user_params.present? && @user.attributes.slice(*user_params.keys) != user_params
      @user.update(user_params)
    end
  end
end

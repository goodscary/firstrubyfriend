class ActiveApplicantMailer < ApplicationMailer
  def month_1
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end

  def month_2
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end

  def month_3
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end

  def month_4
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end

  def month_5
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end

  def month_6
    @mentorship = params[:mentorship]
    @mentor = @mentorship.mentor
    @applicant = @mentorship.applicant
    mail(to: @applicant.email)
  end
end

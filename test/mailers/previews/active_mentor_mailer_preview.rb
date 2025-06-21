# Preview all emails at http://localhost:3000/rails/mailers/active_mentor_mailer
class ActiveMentorMailerPreview < ActionMailer::Preview
  def month_1
    ActiveMentorMailer.with(mentorship: sample_mentorship).month_1
  end

  private

  def sample_mentorship
    Mentorship.new(
      mentor: User.new(email: "mentor_preview@example.com", password: "Password12345!", name: "Mentor Preview"),
      applicant: User.new(email: "applicant_preview@example.com", password: "Password12345!", name: "Applicant Preview"),
      standing: "active"
    )
  end
end

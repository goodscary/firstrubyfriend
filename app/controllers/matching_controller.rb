class MatchingController < ApplicationController
  def index
    @unmatched_applicants = User.unmatched_applicants
  end

  def show
    @applicant = User.find(params[:id])
    @matches = Mentorship.find_matches_for_applicant(@applicant)
  end

  def create
    @applicant = User.find(params[:applicant_id])
    @mentor = User.find(params[:mentor_id])

    @mentorship = Mentorship.new(
      applicant: @applicant,
      mentor: @mentor,
      standing: "active"
    )

    if @mentorship.save
      redirect_to matching_index_path, notice: "Match created successfully!"
    else
      @matches = Mentorship.find_matches_for_applicant(@applicant)
      flash.now[:alert] = "Failed to create match: #{@mentorship.errors.full_messages.join(", ")}"
      render :show, status: :unprocessable_entity
    end
  end
end

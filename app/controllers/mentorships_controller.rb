class MentorshipsController < ApplicationController
  def index
    @mentorships = Mentorship.all
  end

  def new
  end
end

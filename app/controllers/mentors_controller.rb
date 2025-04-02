class MentorsController < ApplicationController
  def index
    @mentors = User.all_mentors
  end
end

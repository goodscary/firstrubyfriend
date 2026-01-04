class PagesController < ApplicationController
  skip_before_action :authenticate
  layout "marketing"

  def early_career
  end

  def mentors
  end

  def conduct
  end
end

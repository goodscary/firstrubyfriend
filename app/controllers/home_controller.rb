class HomeController < ApplicationController
  skip_before_action :authenticate

  def show
    redirect_to dashboard_path and return if Session.find_by_id(cookies.signed[:session_token])
  end
end

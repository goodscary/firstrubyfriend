class HomeController < ApplicationController
  skip_before_action :authenticate
  before_action :set_session_if_present
  layout "marketing"

  def show
    redirect_to dashboard_path and return if Current.session
  end

  private

  def set_session_if_present
    if (session_record = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session_record
    end
  end
end

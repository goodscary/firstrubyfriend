class HomeController < ApplicationController
  skip_before_action :authenticate

  def show
    if (session_record = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session_record
    end
  end
end

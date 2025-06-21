class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/mailer_views"

  default from: "andy@firstrubyfriend.org"
  layout "mailer"
end

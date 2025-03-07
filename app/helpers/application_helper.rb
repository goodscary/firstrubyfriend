module ApplicationHelper
  def current_page_title
    case request.path
    when root_path then ""
    when dashboard_path then "Dashboard"
    when mentors_path then "Mentors"
    when applicants_path then "Applicants"
    when mentorships_path then "Mentorships"
    else ""
    end
  end
end

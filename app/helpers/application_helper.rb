module ApplicationHelper
  def navigation_links
    base_links = Current.user ? { "Dashboard" => dashboard_path } : {}

    return base_links unless Current.user&.admin?

    base_links.merge(
      "Mentors" => mentors_path,
      "Applicants" => applicants_path,
      "Mentorships" => mentorships_path
    )
  end

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

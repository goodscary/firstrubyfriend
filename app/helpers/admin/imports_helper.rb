module Admin::ImportsHelper
  def import_status_badge(report)
    classes = case report.status
    when "pending", "processing"
      "bg-yellow-100 text-yellow-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "failed"
      "bg-red-100 text-red-800"
    end

    content_tag :span, report.status.capitalize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{classes}"
  end
end

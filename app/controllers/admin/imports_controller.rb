module Admin
  class ImportsController < ApplicationController
    def index
      @reports = ImportReport.recent
    end

    def new
    end

    def create
      file = params[:file]

      if file.blank?
        flash.now[:alert] = "Please select a file"
        return render :new, status: :unprocessable_entity
      end

      unless file.original_filename.end_with?(".csv")
        flash.now[:alert] = "File must be a CSV"
        return render :new, status: :unprocessable_entity
      end

      unless %w[mentor applicant match].include?(params[:import_type])
        flash.now[:alert] = "Invalid import type"
        return render :new, status: :unprocessable_entity
      end

      report_id = "#{params[:import_type]}-#{Time.current.to_i}"
      ImportJob.perform_later(params[:import_type], file.read, report_id: report_id)

      redirect_to admin_import_path(report_id), notice: "Import started"
    end

    def show
      @report = ImportReport.find_by!(report_id: params[:id])
    end
  end
end

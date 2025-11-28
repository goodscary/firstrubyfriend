module Admin
  class PendingMatchesController < ApplicationController
    def index
      @pending_matches = Mentorship.pending_approval
        .includes(:mentor, :applicant)
        .order(created_at: :desc)
    end

    def approve
      @mentorship = Mentorship.find(params[:id])

      if @mentorship.pending_approval?
        @mentorship.update!(standing: "active")
        redirect_to admin_pending_matches_path, notice: "Match approved successfully!"
      else
        redirect_to admin_pending_matches_path, alert: "Match is not pending approval."
      end
    end

    def reject
      @mentorship = Mentorship.find(params[:id])

      if @mentorship.pending_approval?
        @mentorship.update!(standing: "ended")
        redirect_to admin_pending_matches_path, notice: "Match rejected."
      else
        redirect_to admin_pending_matches_path, alert: "Match is not pending approval."
      end
    end

    def approve_all
      count = Mentorship.pending_approval.update_all(standing: "active")
      redirect_to admin_pending_matches_path, notice: "Approved #{count} pending matches."
    end

    def auto_match
      service = AutoMatchService.new(minimum_score: 30)
      result = service.run

      if result[:success]
        redirect_to admin_pending_matches_path,
          notice: "Auto-matching complete. Created #{result[:matches_created]} pending matches."
      else
        redirect_to admin_pending_matches_path,
          alert: "Auto-matching completed with #{result[:errors].size} errors. Created #{result[:matches_created]} matches."
      end
    end
  end
end

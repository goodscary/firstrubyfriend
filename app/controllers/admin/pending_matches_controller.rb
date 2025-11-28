module Admin
  class PendingMatchesController < ApplicationController
    def index
      @pending_matches = Mentorship.pending
        .includes(:mentor, :applicant)
        .order(created_at: :desc)
    end

    def approve_all
      count = Mentorship.pending.update_all(standing: "active")
      redirect_to admin_pending_matches_path, notice: "Approved #{count} pending matches."
    end

    def auto_match
      result = Mentorship.auto_match_all(minimum_score: 30)

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

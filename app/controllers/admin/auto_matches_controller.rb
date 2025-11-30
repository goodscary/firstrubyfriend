module Admin
  class AutoMatchesController < ApplicationController
    def create
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

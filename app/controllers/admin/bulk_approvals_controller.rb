module Admin
  class BulkApprovalsController < ApplicationController
    def create
      count = Mentorship.pending.update_all(standing: "active")
      redirect_to admin_pending_matches_path, notice: "Approved #{count} pending matches."
    end
  end
end

module Admin
  class MatchesController < ApplicationController
    def create
      @mentorship = Mentorship.find(params[:id])

      if @mentorship.pending?
        @mentorship.update!(standing: "active")
        redirect_to admin_pending_matches_path, notice: "Match approved successfully!"
      else
        redirect_to admin_pending_matches_path, alert: "Match is not pending."
      end
    end

    def destroy
      @mentorship = Mentorship.find(params[:id])

      if @mentorship.pending?
        @mentorship.update!(standing: "ended")
        redirect_to admin_pending_matches_path, notice: "Match rejected."
      else
        redirect_to admin_pending_matches_path, alert: "Match is not pending."
      end
    end
  end
end

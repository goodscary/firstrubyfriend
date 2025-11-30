module Admin
  class PendingMatchesController < ApplicationController
    def index
      @pending_matches = Mentorship.pending
        .includes(:mentor, :applicant)
        .order(created_at: :desc)
    end
  end
end

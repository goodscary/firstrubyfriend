class AddPendingApprovalToMentorships < ActiveRecord::Migration[8.1]
  # No schema change needed - the standing column is already a string.
  # This migration documents the addition of "pending_approval" to the
  # Mentorship standing enum for auto-matching workflow.
  # Valid standings are now: pending_approval, active, ended
  def change
  end
end

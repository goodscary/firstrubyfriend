class RemoveMenteeQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    drop_table :applicant_questionnaires
  end
end

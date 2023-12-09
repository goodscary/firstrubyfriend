class RemoveYearStartedRubyFromMentorQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    remove_column :mentor_questionnaires, :year_started_ruby, :integer
  end
end

class AddSelfDescriptionAndWnbrbMembershipToMenteeQuestionnaires < ActiveRecord::Migration[7.2]
  def change
    add_column :mentee_questionnaires, :self_description, :text
    add_column :mentee_questionnaires, :wnbrb_member, :boolean
  end
end

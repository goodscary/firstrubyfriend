class CreateApplicantQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    create_table :applicant_questionnaires do |t|
      t.references :respondent, null: false, foreign_key: {to_table: :users}
      t.string :name, null: false
      t.boolean :currently_writing_ruby, null: false
      t.text :where_started_coding, null: false
      t.text :mentorship_goals, null: false
      t.boolean :looking_for_career_mentorship, null: false
      t.boolean :looking_for_code_mentorship, null: false
      t.string :work_url

      t.timestamps
    end
  end
end

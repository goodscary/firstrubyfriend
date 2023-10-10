class CreateMenteeQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table "mentee_questionnaires", id: :binary, force: :cascade do |t|
      t.binary "respondent_id", limit: 16, null: false, foreign_key: true
      t.string :name, null: false
      t.string :work_url
      t.boolean :currently_writing_ruby, null: false
      t.string :where_started_coding, null: false
      t.string :twitter_handle
      t.string :github_handle
      t.string :personal_site_url
      t.string :previous_job
      t.text :mentorship_goals, null: false
      t.boolean :looking_for_career_mentorship, null: false
      t.boolean :looking_for_code_mentorship, null: false

      t.timestamps
    end

    add_foreign_key :mentee_questionnaires, :users, column: :respondent_id
  end
end

class CreateMentorQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table "mentor_questionnaires", id: :binary, force: :cascade do |t|
      t.binary "respondent_id", limit: 16, null: false, foreign_key: true
      t.string :name, null: false
      t.string :company_url, null: false
      t.integer :year_started_ruby, null: false
      t.string :twitter_handle
      t.string :github_handle
      t.string :personal_site_url
      t.text :previous_workplaces
      t.boolean :has_mentored_before, null: false
      t.text :mentoring_reason, null: false
      t.boolean :preferred_style_career, null: false
      t.boolean :preferred_style_code, null: false

      t.timestamps
    end

    add_foreign_key :mentor_questionnaires, :users, column: :respondent_id
  end
end

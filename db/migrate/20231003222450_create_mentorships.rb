class CreateMentorships < ActiveRecord::Migration[7.0]
  def change
    create_table "mentorships", id: :binary, force: :cascade do |t|
      t.binary "mentor_id", limit: 16, null: false, foreign_key: true
      t.binary "applicant_id", limit: 16, null: false, foreign_key: true
      t.string :standing, null: false
      t.datetime :applicant_month_1_email_sent_at
      t.datetime :applicant_month_2_email_sent_at
      t.datetime :applicant_month_3_email_sent_at
      t.datetime :applicant_month_4_email_sent_at
      t.datetime :applicant_month_5_email_sent_at
      t.datetime :applicant_month_6_email_sent_at
      t.datetime :mentor_month_1_email_sent_at
      t.datetime :mentor_month_2_email_sent_at
      t.datetime :mentor_month_3_email_sent_at
      t.datetime :mentor_month_4_email_sent_at
      t.datetime :mentor_month_5_email_sent_at
      t.datetime :mentor_month_6_email_sent_at

      t.timestamps
    end
  end
end

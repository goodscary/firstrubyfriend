# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_05_08_195818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_verification_tokens", id: :binary, force: :cascade do |t|
    t.binary "user_id", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "events", id: :binary, force: :cascade do |t|
    t.binary "user_id", null: false
    t.string "action", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "languages", id: :binary, force: :cascade do |t|
    t.string "iso639_alpha3", null: false
    t.string "iso639_alpha2"
    t.string "english_name"
    t.string "french_name"
    t.string "local_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mentee_questionnaires", id: :binary, force: :cascade do |t|
    t.binary "respondent_id", null: false
    t.string "name", null: false
    t.string "work_url"
    t.boolean "currently_writing_ruby", null: false
    t.string "where_started_coding", null: false
    t.string "twitter_handle"
    t.string "github_handle"
    t.string "personal_site_url"
    t.string "previous_job"
    t.text "mentorship_goals", null: false
    t.boolean "looking_for_career_mentorship", null: false
    t.boolean "looking_for_code_mentorship", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mentor_questionnaires", id: :binary, force: :cascade do |t|
    t.binary "respondent_id", null: false
    t.string "name", null: false
    t.string "company_url", null: false
    t.string "twitter_handle"
    t.string "github_handle"
    t.string "personal_site_url"
    t.text "previous_workplaces"
    t.boolean "has_mentored_before", null: false
    t.text "mentoring_reason", null: false
    t.boolean "preferred_style_career", null: false
    t.boolean "preferred_style_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mentorships", id: :binary, force: :cascade do |t|
    t.binary "mentor_id", null: false
    t.binary "applicant_id", null: false
    t.string "standing", null: false
    t.datetime "applicant_month_1_email_sent_at"
    t.datetime "applicant_month_2_email_sent_at"
    t.datetime "applicant_month_3_email_sent_at"
    t.datetime "applicant_month_4_email_sent_at"
    t.datetime "applicant_month_5_email_sent_at"
    t.datetime "applicant_month_6_email_sent_at"
    t.datetime "mentor_month_1_email_sent_at"
    t.datetime "mentor_month_2_email_sent_at"
    t.datetime "mentor_month_3_email_sent_at"
    t.datetime "mentor_month_4_email_sent_at"
    t.datetime "mentor_month_5_email_sent_at"
    t.datetime "mentor_month_6_email_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "password_reset_tokens", id: :binary, force: :cascade do |t|
    t.binary "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "sessions", id: :binary, force: :cascade do |t|
    t.binary "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_languages", id: :binary, force: :cascade do |t|
    t.binary "user_id", null: false
    t.binary "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :binary, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "unsubscribed_at"
    t.string "unsubscribed_reason"
    t.datetime "available_as_mentor_at"
    t.datetime "requested_mentorship_at"
    t.string "city"
    t.string "country_code"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.integer "demographic_year_of_birth"
    t.integer "demographic_year_started_ruby"
    t.integer "demographic_year_started_programming"
    t.boolean "demographic_underrepresented_group"
    t.text "demographic_underrepresented_group_details"
    t.string "provider"
    t.string "uid"
    t.index ["city"], name: "index_users_on_city"
    t.index ["country_code"], name: "index_users_on_country_code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lat", "lng"], name: "index_users_on_lat_and_lng"
  end

  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "events", "users"
  add_foreign_key "mentee_questionnaires", "users", column: "respondent_id"
  add_foreign_key "mentor_questionnaires", "users", column: "respondent_id"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "sessions", "users"
end

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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000000) do
  create_table "applicant_questionnaires", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "currently_writing_ruby", null: false
    t.boolean "looking_for_career_mentorship", null: false
    t.boolean "looking_for_code_mentorship", null: false
    t.text "mentorship_goals", null: false
    t.string "name", null: false
    t.integer "respondent_id", null: false
    t.datetime "updated_at", null: false
    t.text "where_started_coding", null: false
    t.string "work_url"
    t.index ["respondent_id"], name: "index_applicant_questionnaires_on_respondent_id", unique: true
  end

  create_table "email_verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["action"], name: "index_events_on_action"
    t.index ["user_id", "created_at"], name: "index_events_on_user_and_created_at"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "english_name"
    t.string "french_name"
    t.string "iso639_alpha2"
    t.string "iso639_alpha3", null: false
    t.string "local_name"
    t.datetime "updated_at", null: false
  end

  create_table "mentor_questionnaires", force: :cascade do |t|
    t.string "company_url", null: false
    t.datetime "created_at", null: false
    t.string "github_handle"
    t.boolean "has_mentored_before", null: false
    t.text "mentoring_reason", null: false
    t.string "name", null: false
    t.string "personal_site_url"
    t.boolean "preferred_style_career", null: false
    t.boolean "preferred_style_code", null: false
    t.text "previous_workplaces"
    t.bigint "respondent_id", null: false
    t.string "twitter_handle"
    t.datetime "updated_at", null: false
    t.index ["respondent_id"], name: "index_mentor_questionnaires_on_respondent_id", unique: true
  end

  create_table "mentorships", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.datetime "applicant_month_1_email_sent_at"
    t.datetime "applicant_month_2_email_sent_at"
    t.datetime "applicant_month_3_email_sent_at"
    t.datetime "applicant_month_4_email_sent_at"
    t.datetime "applicant_month_5_email_sent_at"
    t.datetime "applicant_month_6_email_sent_at"
    t.datetime "created_at", null: false
    t.bigint "mentor_id", null: false
    t.datetime "mentor_month_1_email_sent_at"
    t.datetime "mentor_month_2_email_sent_at"
    t.datetime "mentor_month_3_email_sent_at"
    t.datetime "mentor_month_4_email_sent_at"
    t.datetime "mentor_month_5_email_sent_at"
    t.datetime "mentor_month_6_email_sent_at"
    t.string "standing", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id", "standing"], name: "index_mentorships_on_applicant_and_standing"
    t.index ["applicant_id"], name: "index_mentorships_on_applicant_id"
    t.index ["mentor_id", "applicant_id"], name: "index_mentorships_on_mentor_and_applicant", unique: true
    t.index ["mentor_id", "standing"], name: "index_mentorships_on_mentor_and_standing"
    t.index ["mentor_id"], name: "index_mentorships_on_mentor_id"
    t.index ["standing"], name: "index_mentorships_on_standing"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_sessions_on_user_and_created_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "language_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "language_id"], name: "index_user_languages_on_user_and_language", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "available_as_mentor_at"
    t.string "city"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.boolean "demographic_underrepresented_group"
    t.text "demographic_underrepresented_group_details"
    t.integer "demographic_year_of_birth"
    t.integer "demographic_year_started_programming"
    t.integer "demographic_year_started_ruby"
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.string "password_digest"
    t.string "provider"
    t.text "questionnaire_responses", default: "{}"
    t.datetime "requested_mentorship_at"
    t.string "uid"
    t.datetime "unsubscribed_at"
    t.string "unsubscribed_reason"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.index ["available_as_mentor_at"], name: "index_users_on_available_as_mentor_at"
    t.index ["city"], name: "index_users_on_city"
    t.index ["country_code"], name: "index_users_on_country_code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lat", "lng"], name: "index_users_on_lat_and_lng"
    t.index ["requested_mentorship_at"], name: "index_users_on_requested_mentorship_at"
    t.index ["unsubscribed_at", "unsubscribed_reason"], name: "index_users_on_unsubscribed"
    t.index ["verified"], name: "index_users_on_verified"
  end

  add_foreign_key "applicant_questionnaires", "users", column: "respondent_id"
  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "events", "users"
  add_foreign_key "mentor_questionnaires", "users", column: "respondent_id"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "sessions", "users"
end

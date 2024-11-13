class NovemberDbWithSqliteUlid < ActiveRecord::Migration[8.0]
  def change
    create_table "email_verification_tokens", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('email_token')" }
      t.string "user_id", null: false
      t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
    end

    create_table "events", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('event')" }
      t.string "user_id", null: false
      t.string "action", null: false
      t.string "user_agent"
      t.string "ip_address"
      t.timestamps
      t.index ["user_id"], name: "index_events_on_user_id"
    end

    create_table "languages", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('lang')" }
      t.string "iso639_alpha3", null: false
      t.string "iso639_alpha2"
      t.string "english_name"
      t.string "french_name"
      t.string "local_name"
      t.timestamps
    end

    create_table "applicant_questionnaires", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('app_qst')" }
      t.string "respondent_id", null: false
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
      t.timestamps
      t.text "self_description"
      t.boolean "wnbrb_member"
    end

    create_table "mentor_questionnaires", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('ment_qst')" }
      t.string "respondent_id", null: false
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
      t.timestamps
    end

    create_table "mentorships", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('mnt')" }
      t.string "mentor_id", null: false
      t.string "applicant_id", null: false
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
      t.timestamps
    end

    create_table "password_reset_tokens", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('pass_token')" }
      t.string "user_id", null: false
      t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
    end

    create_table "sessions", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('sess')" }
      t.string "user_id", null: false
      t.string "user_agent"
      t.string "ip_address"
      t.timestamps
      t.index ["user_id"], name: "index_sessions_on_user_id"
    end

    create_table "user_languages", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('user_lang')" }
      t.string "user_id", null: false
      t.string "language_id", null: false
      t.timestamps
    end

    create_table "users", id: false, force: :cascade do |t|
      t.primary_key :id, :string, default: -> { "ULID_WITH_PREFIX('user')" }
      t.string "email", null: false
      t.string "password_digest", null: false
      t.boolean "verified", default: false, null: false
      t.timestamps
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
end

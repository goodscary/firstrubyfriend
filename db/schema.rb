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

ActiveRecord::Schema[7.0].define(version: 2023_10_02_025529) do
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
    t.index ["city"], name: "index_users_on_city"
    t.index ["country_code"], name: "index_users_on_country_code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lat", "lng"], name: "index_users_on_lat_and_lng"
  end

  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "events", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "sessions", "users"
end

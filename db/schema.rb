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

ActiveRecord::Schema[7.1].define(version: 2025_07_20_073648) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.bigint "transcription_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transcription_id"], name: "index_analyses_on_transcription_id"
  end

  create_table "dreams", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "audio_file"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tags"
    t.boolean "private"
    t.index ["created_at"], name: "index_dreams_on_created_at"
    t.index ["private"], name: "index_dreams_on_private"
    t.index ["user_id"], name: "index_dreams_on_user_id"
  end

  create_table "personalities", force: :cascade do |t|
    t.integer "age"
    t.string "job"
    t.string "gender"
    t.text "description"
    t.string "relationship"
    t.string "mood"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_personalities_on_user_id"
  end

  create_table "transcriptions", force: :cascade do |t|
    t.bigint "dream_id", null: false
    t.text "content", null: false
    t.string "mood"
    t.string "tag"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_transcriptions_on_created_at"
    t.index ["dream_id"], name: "index_transcriptions_on_dream_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analyses", "transcriptions"
  add_foreign_key "dreams", "users"
  add_foreign_key "personalities", "users"
  add_foreign_key "transcriptions", "dreams"
end

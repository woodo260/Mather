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

ActiveRecord::Schema[8.1].define(version: 2026_03_16_185437) do
  create_table "practice_answers", force: :cascade do |t|
    t.boolean "correct", null: false
    t.datetime "created_at", null: false
    t.integer "difficulty", default: 0, null: false
    t.text "prompt"
    t.string "question_type", null: false
    t.string "session_token", null: false
    t.integer "time_taken_ms"
    t.datetime "updated_at", null: false
    t.index ["session_token", "created_at"], name: "index_practice_answers_on_session_token_and_created_at"
    t.index ["session_token"], name: "index_practice_answers_on_session_token"
  end
end

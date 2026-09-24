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

ActiveRecord::Schema[8.1].define(version: 2026_09_18_122136) do
  create_table "card_reviews", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.date "due_on"
    t.float "ease_factor", default: 2.5, null: false
    t.integer "interval_days", default: 0, null: false
    t.datetime "last_reviewed_at"
    t.integer "repetitions", default: 0, null: false
    t.string "session_token", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_reviews_on_card_id"
    t.index ["session_token", "card_id"], name: "index_card_reviews_on_session_token_and_card_id", unique: true
    t.index ["session_token", "due_on"], name: "index_card_reviews_on_session_token_and_due_on"
  end

  create_table "cards", force: :cascade do |t|
    t.text "back", null: false
    t.datetime "created_at", null: false
    t.integer "deck_id", null: false
    t.text "front", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_cards_on_deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.boolean "builtin", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "session_token"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["session_token"], name: "index_decks_on_session_token"
    t.index ["slug"], name: "index_decks_on_slug", unique: true
  end

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

  add_foreign_key "card_reviews", "cards"
  add_foreign_key "cards", "decks"
end

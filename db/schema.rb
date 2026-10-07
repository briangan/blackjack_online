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

ActiveRecord::Schema[7.2].define(version: 2026_10_06_181233) do
  create_table "games", force: :cascade do |t|
    t.datetime "started_at"
    t.string "status"
    t.integer "dealer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_games_on_status"
  end

  create_table "hands", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "order_index"
    t.float "total_bet_amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "user_id"], name: "index_hands_on_game_id_and_user_id"
    t.index ["game_id"], name: "index_hands_on_game_id"
    t.index ["order_index"], name: "index_hands_on_order_index"
  end

  create_table "play_cards", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "order_index", default: 0
    t.integer "given_user_id"
    t.string "rank"
    t.string "suit"
    t.index ["game_id", "given_user_id"], name: "index_play_cards_on_game_id_and_given_user_id"
    t.index ["game_id"], name: "index_play_cards_on_game_id"
    t.index ["order_index"], name: "index_play_cards_on_order_index"
    t.index ["rank", "suit"], name: "index_play_cards_on_rank_and_suit"
  end

  create_table "users", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.float "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_users_on_type"
  end
end

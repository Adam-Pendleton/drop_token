# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_10_040004) do

  create_table "boards", force: :cascade do |t|
    t.integer "height"
    t.integer "width"
    t.text "board"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "game_players", force: :cascade do |t|
    t.string "active", default: "t"
    t.integer "game_id"
    t.integer "player_id"
    t.index ["game_id", "player_id"], name: "index_game_players_on_game_id_and_player_id"
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["player_id", "game_id"], name: "index_game_players_on_player_id_and_game_id"
    t.index ["player_id"], name: "index_game_players_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.boolean "completed", default: false
    t.string "code"
    t.integer "winner_id"
    t.integer "board_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["board_id"], name: "index_games_on_board_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.string "kind"
    t.integer "column"
    t.integer "move_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "games", "players", column: "winner_id"
end

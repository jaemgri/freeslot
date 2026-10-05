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

ActiveRecord::Schema[8.1].define(version: 2026_10_05_045359) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.datetime "slot_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "slot_at"], name: "index_availabilities_on_participant_id_and_slot_at", unique: true
    t.index ["participant_id"], name: "index_availabilities_on_participant_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.date "start_date"
    t.date "end_date"
    t.integer "start_hour"
    t.integer "end_hour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_token"
    t.index ["owner_token"], name: "index_events_on_owner_token", unique: true
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "name"], name: "index_participants_on_event_id_and_name", unique: true
    t.index ["event_id"], name: "index_participants_on_event_id"
  end

  add_foreign_key "availabilities", "participants"
  add_foreign_key "participants", "events"
end

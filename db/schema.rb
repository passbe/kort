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

ActiveRecord::Schema[8.0].define(version: 2025_10_02_232856) do
  create_table "executions", id: :string, force: :cascade do |t|
    t.string "target_type", null: false
    t.string "target_id", null: false
    t.string "schedule_id"
    t.string "status", null: false
    t.string "log_identifier", null: false
    t.string "message"
    t.json "details"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "counter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_id"], name: "index_executions_on_schedule_id"
    t.index ["target_type", "target_id"], name: "index_executions_on_target"
  end

  create_table "intervals", id: :string, force: :cascade do |t|
    t.boolean "enabled"
    t.string "name", null: false
    t.string "description"
    t.binary "evaluator"
    t.integer "schedules_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "probes", id: :string, force: :cascade do |t|
    t.boolean "enabled"
    t.string "name", null: false
    t.string "description"
    t.string "type", null: false
    t.json "settings"
    t.integer "schedules_count", default: 0, null: false
    t.binary "evaluator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schedules", id: :string, force: :cascade do |t|
    t.string "expression", null: false
    t.datetime "next_execution_at"
    t.string "grace"
    t.datetime "grace_expires_at"
    t.string "target_type", null: false
    t.string "target_id", null: false
    t.index ["next_execution_at"], name: "index_schedules_on_next_execution_at", order: :desc
    t.index ["target_type", "target_id"], name: "index_schedules_on_target"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.string "taggable_id"
    t.string "tagger_type"
    t.string "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "taggings", "tags"
end

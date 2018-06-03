# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180603043730) do

  create_table "gpus", force: :cascade do |t|
    t.string "name"
    t.integer "rig_id"
    t.integer "brand"
    t.string "uuid"
    t.float "memory"
    t.float "utilization"
    t.float "power"
    t.float "temperature"
    t.float "fan"
    t.float "memory_used"
    t.float "power_limit"
    t.integer "mem_clock"
    t.integer "gpu_clock"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rig_id"], name: "index_gpus_on_rig_id"
  end

  create_table "mining_logs", force: :cascade do |t|
    t.integer "rig_id"
    t.text "line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rig_id"], name: "index_mining_logs_on_rig_id"
  end

  create_table "minings", force: :cascade do |t|
    t.integer "rig_id"
    t.integer "code"
    t.text "args"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rig_id"], name: "index_minings_on_rig_id"
  end

  create_table "rigs", force: :cascade do |t|
    t.string "name"
    t.string "uuid"
    t.string "secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

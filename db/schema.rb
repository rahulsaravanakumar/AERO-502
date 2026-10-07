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

ActiveRecord::Schema[8.1].define(version: 2026_10_07_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_projects_on_name", unique: true
  end

  create_table "subteams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "name"], name: "index_subteams_on_team_id_and_name", unique: true
    t.index ["team_id"], name: "index_subteams_on_team_id"
  end

  create_table "task_assignments", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "user_id"], name: "index_task_assignments_on_task_id_and_user_id", unique: true
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
    t.index ["user_id"], name: "index_task_assignments_on_user_id"
  end

  create_table "task_links", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "url", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_links_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.text "instructions"
    t.date "due_date", null: false
    t.decimal "estimated_hours", precision: 7, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.bigint "project_id", null: false
    t.bigint "team_id", null: false
    t.bigint "subteam_id"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date", null: false
    t.index ["creator_id"], name: "index_tasks_on_creator_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["subteam_id"], name: "index_tasks_on_subteam_id"
    t.index ["team_id"], name: "index_tasks_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_teams_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_teams_on_project_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "user_id", null: false
    t.decimal "hours", precision: 7, scale: 2, null: false
    t.string "note"
    t.date "worked_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_time_entries_on_task_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "subteams", "teams"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users"
  add_foreign_key "task_links", "tasks"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "subteams"
  add_foreign_key "tasks", "teams"
  add_foreign_key "tasks", "users", column: "creator_id"
  add_foreign_key "teams", "projects"
  add_foreign_key "time_entries", "tasks"
  add_foreign_key "time_entries", "users"
  add_foreign_key "users", "teams"
end

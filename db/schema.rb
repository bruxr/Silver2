# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140908072604) do

  create_table "cinemas", force: true do |t|
    t.string   "name",                                                    null: false
    t.string   "slug",                                                    null: false
    t.decimal  "latitude",   precision: 15, scale: 10, default: 0.0,      null: false
    t.decimal  "longitude",  precision: 15, scale: 10, default: 0.0,      null: false
    t.string   "status",                               default: "active", null: false
    t.string   "fetcher"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cinemas", ["name"], name: "index_cinemas_on_name", using: :btree
  add_index "cinemas", ["slug"], name: "index_cinemas_on_slug", unique: true, using: :btree

  create_table "movies", force: true do |t|
    t.string   "title",                                             null: false
    t.string   "slug",                                              null: false
    t.text     "overview"
    t.integer  "runtime"
    t.float    "aggregate_score", limit: 24
    t.text     "poster"
    t.text     "backdrop"
    t.text     "trailer"
    t.string   "mtrcb_rating"
    t.string   "status",                     default: "incomplete", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "movies", ["slug"], name: "index_movies_on_slug", unique: true, using: :btree
  add_index "movies", ["title"], name: "index_movies_on_title", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.integer  "movie_id",                      null: false
    t.integer  "cinema_id",                     null: false
    t.datetime "screening_time",                null: false
    t.string   "format",         default: "2D", null: false
    t.text     "ticket_url"
    t.text     "ticket_price"
    t.string   "room",                          null: false
  end

  create_table "sources", force: true do |t|
    t.integer "movie_id",               null: false
    t.string  "name",                   null: false
    t.string  "external_id",            null: false
    t.text    "url",                    null: false
    t.float   "score",       limit: 24
  end

  add_index "sources", ["movie_id"], name: "index_sources_on_movie_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

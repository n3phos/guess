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

ActiveRecord::Schema.define(version: 20150119182249) do

  create_table "gamerecords", force: true do |t|
    t.integer  "theme_id"
    t.integer  "game_id"
    t.integer  "history_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.integer  "history_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "started"
  end

  create_table "histories", force: true do |t|
    t.integer  "gamerecord_id"
    t.string   "media_resolver"
    t.string   "theme_resolver"
    t.string   "interpret_resolver"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: true do |t|
    t.string   "video_id"
    t.integer  "start_seconds"
    t.integer  "end_seconds"
    t.string   "image_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_name"
    t.string   "theme_name"
    t.string   "theme_interpret"
    t.string   "media_image_file_name"
    t.string   "media_image_content_type"
    t.integer  "media_image_file_size"
    t.datetime "media_image_updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "nick"
    t.string   "irc_nick"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

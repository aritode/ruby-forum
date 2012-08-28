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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120810071154) do

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link"
    t.string   "ancestry"
    t.integer  "options"
    t.integer  "display_order", :default => 0
    t.integer  "topic_count",   :default => 0
    t.integer  "post_count",    :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "forums", ["ancestry"], :name => "index_forums_on_ancestry"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "date"
    t.integer  "visible",        :default => 1
    t.integer  "show_signature", :default => 1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "forum_id"
    t.integer  "visible",        :default => 1
    t.integer  "open",           :default => 1
    t.integer  "sticky",         :default => 0
    t.integer  "views",          :default => 0
    t.integer  "replies",        :default => 0
    t.integer  "redirect",       :default => 0
    t.datetime "expires"
    t.integer  "last_poster_id"
    t.datetime "last_post_at"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "usergroups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "usertitle"
    t.integer  "forum_permissions"
    t.string   "open_tag"
    t.string   "close_tag"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "usergroup_id"
    t.string   "membergroup_ids"
    t.integer  "displaygroup_id", :default => 0
    t.string   "title",           :default => ""
    t.integer  "options"
    t.integer  "post_count",      :default => 0
    t.datetime "last_post_at"
    t.integer  "last_post_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

end

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

ActiveRecord::Schema.define(:version => 20120821051407) do

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link"
    t.string   "ancestry"
    t.integer  "options",           :default => 0, :null => false
    t.integer  "display_order",     :default => 0
    t.integer  "topic_count",       :default => 0
    t.integer  "reply_count",       :default => 0
    t.integer  "last_post_id"
    t.integer  "last_post_at"
    t.integer  "last_post_user_id"
    t.integer  "last_topic_at"
    t.integer  "last_topic_id"
    t.integer  "last_topic_title"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "forums", ["ancestry"], :name => "index_forums_on_ancestry"

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.integer  "last_poster_id"
    t.datetime "last_post_at"
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "usergroups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "usertitle"
    t.string   "open_tag"
    t.string   "close_tag"
    t.integer  "forum_permissions"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "usergroup_id"
    t.string   "membergroupids"
    t.integer  "displaygroupid", :default => 0
    t.string   "title",          :default => "Junior Member"
    t.integer  "options"
    t.integer  "post_count",     :default => 0
    t.datetime "lastpost_at"
    t.integer  "lastpost_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

end

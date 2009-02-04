# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090202143238) do

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.integer  "amount",     :limit => 10, :precision => 10, :scale => 0
    t.text     "metadata"
    t.date     "start"
    t.date     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.integer  "city_id"
    t.string   "name"
    t.integer  "factor",     :limit => 10, :precision => 10, :scale => 0
    t.text     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "info"
    t.integer  "city_id"
    t.text     "password_salt"
    t.text     "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

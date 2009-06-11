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

ActiveRecord::Schema.define(:version => 20090611065219) do

  create_table "addresses", :force => true do |t|
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_settings", :force => true do |t|
    t.string   "identifier"
    t.text     "values"
    t.text     "admin_email"
    t.text     "active_dealer_email"
    t.text     "inactive_dealer_email"
    t.text     "home_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "administrator_profiles", :force => true do |t|
    t.integer "administrator_id"
    t.string  "administrator_logo_file_name"
    t.string  "administrator_logo_content_type"
    t.integer "administrator_logo_file_size"
    t.string  "name"
    t.string  "auth_code"
    t.string  "corp_name"
    t.text    "emails_xml"
    t.text    "emails_html"
    t.text    "emails_extra"
    t.string  "first_name"
    t.string  "mid_name"
    t.string  "last_name"
    t.string  "phone_1"
    t.string  "fax"
    t.string  "phone_2"
    t.string  "phone_3"
    t.text    "data_sources"
    t.string  "marketer_net_po"
    t.boolean "wants_data_printed"
    t.text    "comments"
  end

  create_table "csv_extra_fields", :force => true do |t|
    t.text     "fields"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dealer_fields", :force => true do |t|
    t.text     "fields"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",                  :null => false
    t.string  "server_url"
    t.string  "salt",       :default => "", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "auth_code"
    t.text     "emails_xml"
    t.text     "emails_html"
    t.text     "emails_extra"
    t.string   "first_name"
    t.string   "mid_name"
    t.string   "last_name"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "phone_3"
    t.text     "data_sources"
    t.string   "marketer_net_po"
    t.boolean  "wants_data_printed"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "starting_balance",   :default => 1000
    t.integer  "current_balance",    :default => 1000
    t.integer  "administrator_id"
    t.string   "rate",               :default => "1"
    t.text     "text_body_1"
    t.text     "text_body_2"
    t.text     "text_body_3"
    t.string   "variable_data_4"
    t.string   "variable_data_5"
    t.string   "variable_data_6"
    t.string   "variable_data_7"
    t.string   "variable_data_8"
    t.string   "variable_data_9"
  end

  create_table "qd_profiles", :force => true do |t|
    t.string   "listid"
    t.string   "fname"
    t.string   "mname"
    t.string   "lname"
    t.string   "suffix"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "zip4"
    t.string   "crrt"
    t.string   "dpc"
    t.string   "phone_num"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trigger_detail_id"
    t.string   "address2"
    t.integer  "level"
    t.string   "auto17"
    t.integer  "pr01"
    t.string   "status"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "settings", :force => true do |t|
    t.string   "label"
    t.string   "identifier"
    t.text     "description"
    t.string   "field_type",  :default => "string"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trigger_details", :force => true do |t|
    t.integer  "dealer_id"
    t.string   "data_source"
    t.integer  "total_records"
    t.string   "order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "balance"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "identity_url"
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                    :default => "passive"
    t.datetime "remember_token_expires_at"
    t.string   "password_reset_code"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "dealer_id"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end

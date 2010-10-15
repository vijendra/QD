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

ActiveRecord::Schema.define(:version => 20101015043436) do

  create_table "account_resets", :force => true do |t|
    t.integer  "dealer_id"
    t.integer  "user_id"
    t.integer  "unit"
    t.decimal  "rate",       :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "admin_data_appends", :force => true do |t|
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

  create_table "administrator_settings", :force => true do |t|
    t.integer  "administrator_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
  end

  create_table "appended_qd_profiles", :force => true do |t|
    t.integer  "qd_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_append_id", :null => false
  end

  create_table "application_settings", :force => true do |t|
    t.string   "identifier"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csv_extra_fields", :force => true do |t|
    t.text     "fields"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_appends", :force => true do |t|
    t.integer  "requestor_id"
    t.integer  "no_of_records"
    t.integer  "dealer_id"
    t.string   "csv_file_name"
    t.string   "status_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_errors"
    t.integer  "matches"
    t.datetime "completed_on"
  end

  create_table "dealer_fields", :force => true do |t|
    t.text     "fields"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "print_file_fields", :force => true do |t|
    t.integer  "dealer_id"
    t.string   "identifier"
    t.string   "label"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "auth_code"
    t.text     "emails_xml"
    t.text     "emails_html"
    t.text     "emails_extra"
    t.text     "first_name"
    t.text     "mid_name"
    t.text     "last_name"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "phone_3"
    t.text     "data_sources"
    t.string   "marketer_net_po"
    t.boolean  "wants_data_printed"
    t.text     "comments"
    t.integer  "starting_balance",                                 :default => 1000
    t.integer  "current_balance",                                  :default => 1000
    t.decimal  "rate",               :precision => 8, :scale => 2, :default => 0.0
    t.integer  "administrator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  create_table "qd_profiles", :force => true do |t|
    t.string   "listid"
    t.text     "fname"
    t.text     "mname"
    t.text     "lname"
    t.string   "suffix"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "zip4"
    t.string   "crrt"
    t.string   "dpc"
    t.string   "phone_num"
    t.integer  "trigger_detail_id"
    t.string   "address2"
    t.integer  "level"
    t.string   "auto17"
    t.integer  "pr01"
    t.string   "status"
    t.date     "marked_date"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dealer_marked"
    t.string   "fico"
    t.string   "he_lendername"
    t.string   "ddt09"
    t.string   "mtg_lendername"
    t.string   "rev16"
    t.string   "rev24"
    t.string   "mktval02_range"
    t.string   "mktval02"
    t.string   "fhamtgbal"
    t.string   "bk_filing_date"
    t.string   "bk_status"
    t.integer  "appended_landline"
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

  create_table "shell_dimensions", :force => true do |t|
    t.integer  "administrator_id"
    t.integer  "template"
    t.string   "variable"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shell_images", :force => true do |t|
    t.integer  "administrator_id"
    t.integer  "template"
    t.string   "shell_image_file_name"
    t.string   "shell_image_content_type"
    t.integer  "shell_image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_images", :force => true do |t|
    t.string   "site_image_file_name"
    t.string   "site_image_content_type"
    t.integer  "site_image_file_size"
    t.integer  "user_id"
    t.integer  "administrator_id"
    t.integer  "dealer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trigger_details", :force => true do |t|
    t.integer  "dealer_id"
    t.string   "data_source"
    t.integer  "total_records"
    t.string   "order_number"
    t.integer  "balance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_id"
    t.string   "file_password"
    t.string   "file_url"
    t.string   "status"
    t.string   "marked",        :default => "no"
    t.string   "dealer_marked"
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
    t.string   "type"
    t.datetime "remember_token_expires_at"
    t.string   "password_reset_code"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.integer  "administrator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end

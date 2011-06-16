class AddIndexToAllTables < ActiveRecord::Migration
  def self.up
    add_index :account_resets, :dealer_id
    add_index :account_resets, :user_id

    add_index :addresses, :user_id
    add_index :administrator_profiles, :administrator_id
    add_index :administrator_settings, :administrator_id
    add_index :administrator_settings, :identifier
    add_index :appended_qd_profiles, :qd_profile_id
    add_index :appended_qd_profiles, :data_append_id
    add_index :application_settings, :identifier
    add_index :csv_extra_fields, :dealer_id
    add_index :data_appends,:requestor_id
    add_index :data_appends,:dealer_id
    add_index :data_appends,:status_message

    add_index :data_appends,:tid
    add_index :dealer_fields, :dealer_id
    add_index :print_file_fields  ,:dealer_id
    add_index :print_file_fields  ,:identifier
    add_index :profiles,:user_id
    add_index :profiles, :administrator_id

    add_index :qd_profiles, :listid
    add_index :qd_profiles, :dealer_id
    add_index :qd_profiles, :status
    add_index :qd_profiles, :trigger_detail_id

    add_index :roles_users, :user_id
    add_index :roles_users, :role_id
    add_index :settings, :label
    add_index :settings, :identifier
    add_index :shell_dimensions, :administrator_id
    add_index :shell_dimensions, :template
    add_index :shell_dimensions, :variable
    add_index :shell_images, :administrator_id
    add_index :shell_images, :template
    add_index :site_images, :user_id
    add_index :site_images, :administrator_id
    add_index :site_images, :dealer_id
    add_index :trigger_details, :dealer_id
    add_index :trigger_details, :data_source
    add_index :trigger_details, :status
    add_index :trigger_details, :balance
    add_index :trigger_details, :marked
    add_index :trigger_details, :order_number
    add_index :trigger_details, :created_at


    add_index :users, :email
    add_index :users, :state
    add_index :users, :type


  end

  def self.down
  end
end


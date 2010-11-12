class AddAppendFieldsToQdProfile < ActiveRecord::Migration
  def self.up
    remove_column :qd_profiles, :appended_landline 
    add_column :qd_profiles, :landline, :string
    add_column :qd_profiles, :mobile, :string
    add_column :qd_profiles, :email, :string
  end

  def self.down
  end
end

class AddFieldToQdProfile < ActiveRecord::Migration
  def self.up
    add_column :qd_profiles, :appended_landline, :string
  end

  def self.down
  end
end

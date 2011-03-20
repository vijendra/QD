class AddFieldToQdprofile < ActiveRecord::Migration
  def self.up
    add_column :qd_profiles, :dnd, :boolean, :default => false
  end

  def self.down
  end
end

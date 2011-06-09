class RemoveMobileAppendFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :mobile_append
  end

  def self.down
  end
end


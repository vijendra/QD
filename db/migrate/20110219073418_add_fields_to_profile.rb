class AddFieldsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :ncoa_append, :boolean, :default => true
  end

  def self.down
  end
end

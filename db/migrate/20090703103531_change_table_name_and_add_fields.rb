class ChangeTableNameAndAddFields < ActiveRecord::Migration
  def self.up
  	 rename_table :admin_settings, :application_settings
  	 rename_table :disclaimer_contents, :administrator_settings
  	 add_column :administrator_settings  :identifier , :string
  end

  def self.down
  end
end

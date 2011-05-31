class AddDatasourceFieldsToAdministratorProfile < ActiveRecord::Migration
  def self.up
    add_column :administrator_profiles, :datasource_username, :string
    add_column :administrator_profiles, :datasource_password, :string
  end

  def self.down
    remove_column :administrator_profiles, :datasource_username
    remove_column :administrator_profiles, :datasource_password
  end
end


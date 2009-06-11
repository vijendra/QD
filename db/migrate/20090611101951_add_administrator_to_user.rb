class AddAdministratorToUser < ActiveRecord::Migration
  def self.up
  	add_column :users, :administrator_id, :integer
  end

  def self.down
  end
end

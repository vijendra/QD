class AddFieldsToDealers < ActiveRecord::Migration
  def self.up
    add_column :profiles, :starting_balance, :integer, :default => 1000
    add_column :profiles, :current_balance, :integer, :default => 1000
    add_column :profiles, :rate, :string, :default => 1
  end

  def self.down
  end
end

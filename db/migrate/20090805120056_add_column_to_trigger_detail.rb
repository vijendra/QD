class AddColumnToTriggerDetail < ActiveRecord::Migration
  def self.up
    add_column :trigger_details, :dealer_marked, :string
    add_column :qd_profiles, :dealer_marked, :string
  end

  def self.down
    remove_column :trigger_details, :dealer_marked
    remove_column :qd_profiles, :dealer_marked
  end
end

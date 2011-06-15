class AddDncScheduleToDealerProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :dnc_schedule, :string
  end

  def self.down
    remove_column :profiles, :dnc_schedule
  end
end


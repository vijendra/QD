class AddIndexToDncNumberTables < ActiveRecord::Migration
  def self.connection
    DncNumber.connection
  end
  def self.up
    add_index :dnc_numbers, :dealer_id
    add_index :dnc_numbers, :number
  end

  def self.down
  end
end


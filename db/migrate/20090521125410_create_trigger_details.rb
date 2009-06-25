class CreateTriggerDetails < ActiveRecord::Migration
  def self.up
    create_table :trigger_details do |t|
      t.references :dealer
      t.string :data_source
      t.integer :total_records
      t.string :order_number
      t.integer :balance

      t.timestamps
    end
  end

  def self.down
    drop_table :trigger_details
  end
end

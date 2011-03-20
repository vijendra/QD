class CreateDncNumbers < ActiveRecord::Migration
  def self.connection
    DncNumber.connection
  end
  
  def self.up
    create_table :dnc_numbers do |t|
      t.string :number
      t.integer :dealer_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dnc_numbers
  end
end

class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :postal_code
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end

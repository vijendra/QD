class CreateDealerFields < ActiveRecord::Migration
  def self.up
    create_table :dealer_fields do |t|

      t.text :fields
      t.references :dealer

      t.timestamps
    end
  end

  def self.down
    drop_table :dealer_fields
  end
end

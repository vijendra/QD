class CreateAdminPrintFileFields < ActiveRecord::Migration
  def self.up
    create_table :print_file_fields do |t|
      t.integer :dealer_id
      t.string :identifier
      t.string :label
      t.text :values
      t.timestamps
    end
  end

  def self.down
    drop_table :print_file_fields
  end
end

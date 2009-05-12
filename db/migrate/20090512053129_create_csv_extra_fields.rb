class CreateCsvExtraFields < ActiveRecord::Migration
  def self.up
    create_table :csv_extra_fields do |t|
      t.text :fields
      t.references :dealer
      t.timestamps
    end
  end

  def self.down
    drop_table :csv_extra_fields
  end
end

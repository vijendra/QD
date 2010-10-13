class CreateDataAppends < ActiveRecord::Migration
  def self.up
    create_table :data_appends do |t|
      t.integer :requestor_id
      t.integer :no_of_records
      t.integer :dealer_id
      t.string :csv_file_name
      t.string :status_message
     
      t.timestamps
    end
  end

  def self.down
    drop_table :data_appends
  end
end

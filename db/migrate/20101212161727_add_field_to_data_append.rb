class AddFieldToDataAppend < ActiveRecord::Migration
  def self.up
    add_column :data_appends, :tid, :integer
  end

  def self.down
  end
end

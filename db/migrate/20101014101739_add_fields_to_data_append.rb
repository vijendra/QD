class AddFieldsToDataAppend < ActiveRecord::Migration
  def self.up
    add_column :data_appends, :total_errors, :integer
    add_column :data_appends, :matches, :integer
    add_column :data_appends, :completed_on, :datetime
  end

  def self.down
  end
end

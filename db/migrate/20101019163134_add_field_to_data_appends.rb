class AddFieldToDataAppends < ActiveRecord::Migration
  def self.up
    add_column :data_appends, :product, :string
  end

  def self.down
    remove_column :data_appends, :product
  end
end

class AddDealerToUser < ActiveRecord::Migration
  def self.up
  	add_column :users, :dealer_id, :integer
  end

  def self.down
  end
end

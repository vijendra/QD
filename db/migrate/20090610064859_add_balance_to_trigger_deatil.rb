class AddBalanceToTriggerDeatil < ActiveRecord::Migration
  def self.up
  		add_column :trigger_details, :balance, :integer
  end

  def self.down
  end
end

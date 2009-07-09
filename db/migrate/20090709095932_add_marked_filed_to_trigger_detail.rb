class AddMarkedFiledToTriggerDetail < ActiveRecord::Migration
  def self.up
     add_column :trigger_details, :marked , :string
  end

  def self.down
  end
end

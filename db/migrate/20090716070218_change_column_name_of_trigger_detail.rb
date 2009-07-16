class ChangeColumnNameOfTriggerDetail < ActiveRecord::Migration
  def self.up
    change_column :trigger_details, :marked, :string, :default => 'no'
    
    records = TriggerDetail.find(:all ,:conditions => ["marked IS null"])
    records.each do | rec|
      rec.marked = 'no'
      rec.save!
    end
    
  end

  def self.down
  end
end

 

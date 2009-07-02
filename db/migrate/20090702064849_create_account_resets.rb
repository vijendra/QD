class CreateAccountResets < ActiveRecord::Migration
  def self.up
    create_table :account_resets do |t|

    	t.integer :dealer_id
    	t.integer :user_id
    	t.integer :unit
    	t.column :rate, :decimal, :precision => 8, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :account_resets
  end
end

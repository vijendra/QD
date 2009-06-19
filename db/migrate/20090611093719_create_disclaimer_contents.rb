class CreateDisclaimerContents < ActiveRecord::Migration
  def self.up
    create_table :disclaimer_contents do |t|
    	t.integer :administrator_id
    	t.text :value

      t.timestamps
    end
  end

  def self.down
    drop_table :disclaimer_contents
  end
end

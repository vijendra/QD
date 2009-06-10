class CreateAdminSettings < ActiveRecord::Migration
  def self.up
    create_table :admin_settings do |t|

    	t.string :identifier
    	t.text :values
   # 	t.text :admin_email
    #	t.text :active_dealer_email
    	#t.text :inactive_dealer_email
    #	t.text :home_text

      t.timestamps

    end

  end

  def self.down
    drop_table :admin_settings
  end
end

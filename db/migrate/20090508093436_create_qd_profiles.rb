class CreateQdProfiles < ActiveRecord::Migration
  def self.up
    create_table :qd_profiles do |t|
      t.string :listid
      t.string :fname
      t.string :mname
      t.string :lname 
      t.string :suffix
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :zip4
      t.string :crrt
      t.string :dpc
      t.string :phone_num
      t.references :dealer

      t.timestamps
    end
  end

  def self.down
    drop_table :qd_profiles
  end
end

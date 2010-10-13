class CreateAdminAppendedQdProfiles < ActiveRecord::Migration
  def self.up
    create_table :admin_appended_qd_profiles do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_appended_qd_profiles
  end
end

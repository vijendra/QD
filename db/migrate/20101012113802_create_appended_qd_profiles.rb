class CreateAppendedQdProfiles < ActiveRecord::Migration
  def self.up
    create_table :appended_qd_profiles do |t|
      t.integer :qd_profile_id
      t.integer :data_append_id
      t.timestamps
    end
  end

  def self.down
    drop_table :appended_qd_profiles
  end
end

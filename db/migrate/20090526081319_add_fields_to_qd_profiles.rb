class AddFieldsToQdProfiles < ActiveRecord::Migration
  def self.up
    add_column :qd_profiles, :trigger_detail_id, :integer
    add_column :qd_profiles, :address2, :string
    add_column :qd_profiles, :level, :integer
    add_column :qd_profiles, :auto17, :string
    add_column :qd_profiles, :pr01, :integer
  end

  def self.down
    remove_column :qd_profiles, :trigger_detail_id
    remove_column :qd_profiles, :address2
    remove_column :qd_profiles, :level
    remove_column :qd_profiles, :auto17
    remove_column :qd_profiles, :pr01
  end
end

class AddRenameLandlineAndAddDaLandlineToQdProfiles < ActiveRecord::Migration
  def self.up
    rename_column :qd_profiles, :landline , :compiled_landline
    add_column :qd_profiles,  :da_landline ,:string
  end

  def self.down
  end
end


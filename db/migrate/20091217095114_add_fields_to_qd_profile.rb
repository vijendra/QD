class AddFieldsToQdProfile < ActiveRecord::Migration
  def self.up
    add_column :qd_profiles, :he_lendername, :string
	add_column :qd_profiles, :ddt09, :string
	add_column :qd_profiles, :mtg_lendername, :string
	add_column :qd_profiles, :rev16, :string
	add_column :qd_profiles, :rev24, :string
	add_column :qd_profiles, :mktval02_range, :string
	add_column :qd_profiles, :mktval02, :string
	add_column :qd_profiles, :fhamtgbal, :string
  end

  def self.down
  end
end

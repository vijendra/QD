class RemoveUnwantedFieldsFomQdProfile < ActiveRecord::Migration
  def self.up
    remove_column :qd_profiles, :he_lendername
    remove_column :qd_profiles, :mtg_lendername
    remove_column :qd_profiles, :rev16
    remove_column :qd_profiles, :rev24
    remove_column :qd_profiles, :mktval02_range
    remove_column :qd_profiles, :mktval02
    remove_column :qd_profiles, :fhamtgbal
    remove_column :qd_profiles, :bk_filing_date
    remove_column :qd_profiles, :bk_status


  end

  def self.down
  end
end


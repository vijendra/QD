class AddBkFieldsToQdProfle < ActiveRecord::Migration
  def self.up
    add_column :qd_profiles, :bk_filing_date, :string
    add_column :qd_profiles, :bk_status, :string
  end

  def self.down
  end
end

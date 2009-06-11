class AddStateToQdProfile < ActiveRecord::Migration
  def self.up
  	 add_column :qd_profiles, :status, :string
  end

  def self.down
  end
end

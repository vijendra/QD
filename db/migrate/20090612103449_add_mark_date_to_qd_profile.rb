class AddMarkDateToQdProfile < ActiveRecord::Migration
  def self.up
  	 add_column :qd_profiles, :marked_date, :date
  end

  def self.down
  end
end

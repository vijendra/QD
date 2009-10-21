class AddFicoToQdProfile < ActiveRecord::Migration
  def self.up
     add_column :qd_profiles, :fico , :string
  end

  def self.down
    
  end
end

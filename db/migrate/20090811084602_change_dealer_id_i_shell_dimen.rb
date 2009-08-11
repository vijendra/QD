class ChangeDealerIdIShellDimen < ActiveRecord::Migration
  def self.up
     rename_column :shell_dimensions , :dealer_id, :administrator_id
  end

  def self.down
  end
end

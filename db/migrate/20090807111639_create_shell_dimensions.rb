class CreateShellDimensions < ActiveRecord::Migration
  def self.up
    create_table :shell_dimensions do |t|
      t.integer :dealer_id
      t.integer :template
      t.string  :variable
      t.string  :x
      t.string  :y

      t.timestamps
    end
  end

  def self.down
    drop_table :shell_dimensions
  end
end

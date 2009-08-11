class CreateShellImages < ActiveRecord::Migration
  def self.up
    create_table :shell_images do |t|
      t.integer :administrator_id
      t.integer :template
      t.string :shell_image_file_name
      t.string :shell_image_content_type
      t.integer :shell_image_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :shell_images
  end
end

class CreateSiteImages < ActiveRecord::Migration
  def self.up
    create_table :site_images do |t|

      t.string :site_image_file_name
      t.string :site_image_content_type
      t.integer :site_image_file_size
      t.integer :user_id
      t.integer :administrator_id
      t.integer :dealer_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_images
  end
end

class CreateAdminAdministratorProfiles < ActiveRecord::Migration
  def self.up
    create_table :administrator_profiles do |t|

      t.references :administrator

      t.string :administrator_logo_file_name
      t.string :administrator_logo_content_type
      t.integer :administrator_logo_file_size
      t.string :name
      t.string :auth_code
      t.string :corp_name
      t.text :emails_xml
      t.text :emails_html
      t.text :emails_extra
      t.string :first_name
      t.string :mid_name
      t.string :last_name
      t.string :phone_1
      t.string :fax
      t.string :phone_2
      t.string :phone_3
      t.text :data_sources
      t.string :marketer_net_po
      t.boolean :wants_data_printed
      t.text :comments

    end
  end

  def self.down
    drop_table :administrator_profiles
  end
end

class AddDncFieldsToDealer < ActiveRecord::Migration
  def self.up
    add_column :profiles, :dnc_user_name, :string
    add_column :profiles, :dnc_password, :string
    add_column :profiles, :email_append, :boolean, :default => false
    add_column :profiles, :phone_append, :boolean, :default => false
    add_column :profiles, :mobile_append, :boolean, :default => false
  end

  def self.down
  end
end

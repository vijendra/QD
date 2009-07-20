class UpdateLoginAndChnageProfileName < ActiveRecord::Migration
  def self.up
     add_column :profiles ,:display_name ,:string
     profiles = Profile.find(:all)
     profiles.each do |profile| 
       profile.update_attributes(:display_name => profile.name ) 
     end
  end

  def self.down
  end
end

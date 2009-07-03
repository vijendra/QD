class SiteImage < ActiveRecord::Base
   belongs_to :user
   has_attached_file :site_image , :styles => { :thumb=> "200x200>", :small  => "150x150>" }
end

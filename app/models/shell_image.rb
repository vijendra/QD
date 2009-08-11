class ShellImage < ActiveRecord::Base
  has_attached_file :shell_image , :styles => { :thumb=> "200x200>", :small  => "150x150>" }
end

class AdministratorProfile < ActiveRecord::Base
	belongs_to :administrator

	has_attached_file :administrator_logo , :styles => { :thumb=> "200x200#", :small  => "150x150>" }
end

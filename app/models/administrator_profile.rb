class AdministratorProfile < ActiveRecord::Base
	belongs_to :administrator

	has_attached_file :administrator_logo , :styles => { :thumb=> "100x100#", :small  => "150x150>" }
end

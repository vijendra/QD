module Admin::AdministratorsHelper

	def acitive_inactive_dealer(id,text)
		count = 0
		count = Profile.find(:all,:include =>:user , :conditions => {:administrator_id => "#{id}" , :user => {:state => "#{text}"} } ).size

		count.nil? ?  0 : count
	end


end

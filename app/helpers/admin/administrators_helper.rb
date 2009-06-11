module Admin::AdministratorsHelper

	def acitive_inactive_dealer(id,text)
		count = 0
		count = User.find(:all, :conditions => ["administrator_id = ? and state = ?" ,id,text] ).size

		count.nil? ?  0 : count
	end


end

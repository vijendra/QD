module Admin::PrintDataHelper

	def find_qd_profile_for_date(date)
		profiles =  @dealer.qd_profiles.find(:all,:conditions =>["status = ? and marked_date = ?","marked",date])
	end
end

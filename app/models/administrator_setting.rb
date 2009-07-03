class AdministratorSetting < ActiveRecord::Base
	belongs_to :administrator

	 named_scope :by_administrator_and_identifier, lambda{|id,identifier| {:conditions => ["administrator_id = ? AND identifier = ?", id ,identifier] } }
end

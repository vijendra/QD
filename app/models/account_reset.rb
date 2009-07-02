class AccountReset < ActiveRecord::Base
	belongs_to :dealer

	named_scope :by_date_filter, { :conditions => ["created_at > ?   ", (Time.now - 60.day).to_date]}
end

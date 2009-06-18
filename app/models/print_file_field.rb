class PrintFileField < ActiveRecord::Base
  belongs_to :dealer
  
  named_scope :by_dealer, lambda { |dealer_id| { :conditions => "dealer_id =  #{dealer_id}" } }
  named_scope :by_identifier, lambda { |identifier| { :conditions => ["identifier = ?",  identifier] } }
end

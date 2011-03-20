class TriggerDetail < ActiveRecord::Base
  include AASM

  belongs_to :dealer
  has_many :qd_profiles

  aasm_column :status
  aasm_initial_state :unprocessed

  aasm_state :unprocessed
  aasm_state :processed

  aasm_event :process do
    transitions :to => :processed, :from => [:unprocessed]
  end

  def make_processed
    self.process!
    
    #set data append requests, if selected for the dealer  
    DataAppend.create(:no_of_records => self.total_records, :dealer_id => self.dealer_id, :tid => self.id, :requestor_id =>  '', :status_message => 'sent', :product => 'ncoa') if self.dealer.profile.ncoa_append

    DataAppend.create(:no_of_records => self.total_records, :dealer_id => self.dealer_id, :tid => self.id, :requestor_id =>  '', :status_message => 'sent', :product => 'll') if self.dealer.profile.phone_append
   
    DataAppend.create(:no_of_records => self.total_records, :dealer_id => self.dealer_id, :tid => self.id, :requestor_id =>  '', :status_message => 'sent', :product => 'mb') if self.dealer.profile.mobile_append
       
    DataAppend.create(:no_of_records => self.total_records, :dealer_id => self.dealer_id, :tid => self.id, :requestor_id =>  '', :status_message => 'sent', :product => 'em') if self.dealer.profile.email_append
  end
end

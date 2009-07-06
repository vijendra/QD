class QdProfile < ActiveRecord::Base
	include AASM
  belongs_to :dealer


  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :marked
  aasm_state :dealer_printed
  aasm_state :printed


  aasm_event :mark_visited do
    transitions :to => :marked, :from => [:new ,:dealer]
  end

  aasm_event :print do
    transitions :to => :printed, :from => [:marked ,:printed]
  end
  
  aasm_event :dealer_print do
    transitions :to => :dealer_printed, :from => [:marked]
  end

  named_scope :to_be_printed, {:conditions => ["status like ?",  'marked'] }
end

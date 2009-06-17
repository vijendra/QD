class QdProfile < ActiveRecord::Base
	include AASM
  belongs_to :dealer


  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :marked
  aasm_state :printed


  aasm_event :mark_visited do
    transitions :to => :marked, :from => [:new ,:marked]
  end
  aasm_event :print do
    transitions :to => :printed, :from => [:marked ,:printed]
  end

  named_scope :to_be_printed, {:conditions => ["status like ?",  'marked'] }
end

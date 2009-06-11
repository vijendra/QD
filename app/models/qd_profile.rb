class QdProfile < ActiveRecord::Base
	include AASM
  belongs_to :dealer


  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :visited



  aasm_event :mark_visited do
    transitions :to => :visited, :from => [:new]
  end
end

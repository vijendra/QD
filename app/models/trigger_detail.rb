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


end

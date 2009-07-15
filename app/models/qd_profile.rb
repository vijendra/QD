class QdProfile < ActiveRecord::Base
  include AASM
  belongs_to :dealer
  belongs_to :trigger_detail

  PRIVATE_FIELDS = ["id", "created_at", "updated_at", "dealer_id", "trigger_detail_id", "status", "marked_date"]
  SEEKERNIC_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ]
  TRANSACTIS_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM', 'ADDRESS 2', ' LEVEL', 'AUTO17', 'PR01']

  def self.public_attributes
    self.new.attribute_names.select{|a| !QdProfile::PRIVATE_FIELDS.include?(a)}.sort
  end

  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :marked
  aasm_state :dealer_printed
  aasm_state :printed


  aasm_event :mark do
    transitions :to => :marked, :from => [:new, :printed, :marked, :dealer_printed]
  end

  aasm_event :print do
    transitions :to => :printed, :from => [:marked, :printed]
  end
  
  aasm_event :dealer_print do
    transitions :to => :dealer_printed, :from => [:marked]
  end
  
  aasm_event :un_mark do
    transitions :to => :new, :from => [:marked]
  end

  named_scope :to_be_printed, {:conditions => ["status like ?",  "marked"] }
end

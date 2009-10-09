class QdProfile < ActiveRecord::Base
  include AASM
  belongs_to :dealer
  belongs_to :trigger_detail 

  PRIVATE_FIELDS = ["id", "created_at", "updated_at", "dealer_id", "trigger_detail_id", "status", "marked_date","level","auto17","dealer_marked"]
  SEEKERNIC_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ]
  TRANSACTIS_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM', 'ADDRESS 2', ' LEVEL', 'AUTO17', 'PR01']

  QDPROFILE_HEADERS = { 'listid' => 'Order id', 'fname' => 'First Name' ,'mname' => 'Mid Name','lname' => 'Last Name', 'suffix' =>'suffix', 'address' => 'address','address2' => 'address2','city' => 'city', 'state' => 'state','zip' => 'zip','zip4' => 'zip4','crrt' =>'ccrt','dpc' => 'dpc','phone_num' =>'Phone' ,'pr01' => 'pr01' }
 
  QDPROFILE_CSV_HEADERS = ['Order id','First Name','Mid Name','Last Name','Suffix','Address','City', 'State','Zip', 'Zip4','Ccrt', 'dpc', 'Phone' ]
  QDPROFILE_CSV_FIELDS = ['listid','fname','mname','lname','suffix','address','city','state','zip','zip4','crrt','dpc','phone_num']
  
  FIELDS_TO_BE_SHOWN = ['listid','fname','mname','lname','suffix','address','address2','city','state','zip','zip4','crrt','dpc','phone_num','pr01']
	

  
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
    transitions :to => :printed, :from => [:marked, :printed,:new]
  end
  
  aasm_event :dealer_print do
    transitions :to => :dealer_printed, :from => [:marked]
  end
  
  aasm_event :un_mark do
    transitions :to => :new, :from => [:marked]
  end

  named_scope :to_be_printed, {:conditions => ["status like ?",  "marked"] }
  named_scope :to_be_unmark_printed, {:conditions => ["status like ?",  "new"] }
  named_scope :to_be_dealer_printed, {:conditions => ["dealer_marked like ?",  "yes"] }
end

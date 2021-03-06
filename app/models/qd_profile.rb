class QdProfile < ActiveRecord::Base
  include AASM
  belongs_to :dealer
  belongs_to :trigger_detail
  has_many :appended_qd_profiles
  has_many :data_appends, :through => :appended_qd_profiles

  PRIVATE_FIELDS = ["id", "created_at", "updated_at", "dealer_id", "trigger_detail_id", "status", "marked_date", "level", "dealer_marked"]
  SEEKERNIC_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ]
  TRANSACTIS_LABELS = ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM', 'ADDRESS 2', ' LEVEL', 'AUTO17', 'PR01']

  QDPROFILE_HEADERS = { 'listid' => 'Order id', 'fname' => 'First Name' ,'mname' => 'Mid Name','lname' => 'Last Name', 'suffix' =>'suffix', 'address' => 'address','address2' => 'address2','city' => 'city', 'state' => 'state','zip' => 'zip','zip4' => 'zip4','crrt' =>'ccrt','dpc' => 'dpc','phone_num' =>'Phone', 'landline' => 'Appended landline', 'mobile' => 'Appended mobile', 'email' => 'Appended email' }

  QDPROFILE_CSV_HEADERS = ['Order id','First Name','Mid Name','Last Name','Suffix','Address','City', 'State','Zip', 'Zip4','Ccrt', 'dpc', 'Phone','fico', 'PR01','COMPILED LANDLINE', 'DA LANDLINE','MOBILE', 'EMAIL']

  QDPROFILE_CSV_FIELDS = ['listid','fname','mname','lname','suffix','address','city','state','zip','zip4','crrt','dpc','phone_num','pr01','fico', 'compiled_landline','da_landline', 'mobile', 'email' ]

  FIELDS_TO_BE_SHOWN =  ['listid','fname','mname','lname','suffix','address','address2','city','state','zip','zip4','crrt','dpc','phone_num', 'compiled_landline', 'mobile', 'email','da_landline' ]


  IMPORT_FILE_FIELDS = {'LISTID' => 'listid', 'LNAME' => 'lname', 'FNAME' => 'fname', 'MI' => 'mname',
                'MNAME' => 'mname', 'SUFFIX' => 'suffix' , 'ADDRESS' => 'address', 'ADDR1' => 'address', 'ADDR2' => 'address2',
				'CITY' => 'city', 'STATE' => 'state', 'ZIP' => 'zip', 'ZIP4' => 'zip4', 'LEVEL' => 'level',
				'FICO' => 'fico', 'AUTO17' => 'auto17', 'PR01' => 'pr01', 'PHONE' =>'phone_num', 'PHONE_NUM' =>'phone_num',
				'CRRT' => 'crrt',  'DPCD' => 'dpc',  'DPC' => 'dpc', 'DDT09' => 'ddt09', 'COMPILED LANDLINE' =>  'compiled_landline',
				'DA LANDLINE' => 'da_landline', 'MOBILE' => 'mobile', 'EMAIL' => 'email'}

  DATA_APPEND_FIELDS = {'id' => 'id', 'first name' => 'fname',  'last name' => 'lname',  'address' => 'address', 'city' => 'city', 'state' => 'state', 'zip' => 'zip'}
  DATA_APPEND_HEADERS = ['id', 'first name', 'last name', 'address', 'city',  'state', 'zip'] #We could use keys on above hash. but order of fields are altered.

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
  named_scope :valid_adddress, {:conditions => ["address != 'MOVED, NO FORWARDING ADDRESS'"] }
  
  #named_scope :by_landline, lambda{|num| :conditions => ["landline = ?",  num] }
  #named_scope :by_mobile, lambda{|num| :conditions => ["mobile = ?",  num] }

  def full_addrress
    "#{address}, #{city}, #{state} - #{zip}"
  end
  
  def formatted_zip
    if self.zip.include?('-')
      self.zip.gsub('-', '')
    else
      "#{self.zip}#{self.zip4}"
    end
  end
end


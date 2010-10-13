class Dealer < User
  has_many :qd_profiles
  has_one :dealer_field
  has_one :csv_extra_field
  has_many :trigger_details
  has_many :print_file_fields
  has_many :account_resets
  belongs_to :administrator
  has_many :data_apppends

  def self.dealers_list
    self.find(:all).collect{|dealer| [dealer.profile.name, dealer.id] }
  end

  def self.administrator_dealers_list(id)
    self.find(:all,:conditions => ["administrator_id = ?",id]).collect{|dealer| [dealer.profile.name, dealer.id]}
  end

  aasm_state :inactive

  aasm_event :deactivate do
    transitions :to => :inactive, :from => [:pending, :active, :passive]
  end

  aasm_event :active do
    transitions :to => :active, :from => [:pending, :inactive, :passive]
  end

  named_scope :active_dealers, {:conditions => ["state = ?",  'active'] }
  named_scope :inactive_dealers, {:conditions => ["state = ?",  'inactive'] }
  
   def self.profile_field_values(fields, dealer)
     profile = dealer.profile
     values = {}
     fields.map{|field| unless Profile::PRINT_FILE_VARIABELS.include?(field)
                        if field == "phone_num"
                          values[field] = "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}" rescue ''
                        else
                          #if not found in profile check in adrs.
                          values[field] = eval("profile.#{field}") rescue eval("dealer.address.#{field}")
                        end
                      end
                }
    return values
  end
  
end

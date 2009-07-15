class Dealer < User
  has_many :qd_profiles
  has_one :dealer_field
  has_one :csv_extra_field
  has_many :trigger_details
  has_many :print_file_fields
  has_many :account_resets
  belongs_to :administrator

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
end

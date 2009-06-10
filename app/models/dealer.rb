class Dealer < User
  has_many :qd_profiles
  has_one :dealer_field
  has_one :csv_extra_field
  has_many :trigger_details

  def self.dealers_list
    self.find(:all).collect{|dealer| [dealer.profile.name, dealer.id] }
  end

end

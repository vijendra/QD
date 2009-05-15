class Dealer < User
  has_many :qd_profiles
  has_one :dealer_field
  has_one :csv_extra_field

  def self.dealers_list
    self.find(:all).collect{|dealer| [dealer.login, dealer.id] }
  end

end

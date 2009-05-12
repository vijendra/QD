class Dealer < User
  has_many :qd_profiles
  has_one :dealer_field
  has_one :csv_extra_field
end

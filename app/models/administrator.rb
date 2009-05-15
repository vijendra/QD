class Administrator < User
  has_one :administrator_profile


  accepts_nested_attributes_for :administrator_profile

end

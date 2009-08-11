class Administrator < User
  has_one :administrator_profile
  has_one :administrator_setting
  has_many :dealers
  has_many :shell_dimensions

  accepts_nested_attributes_for :administrator_profile

   def self.administrators_list
     self.find(:all).collect{|admin| [admin.login, admin.id] }
  end

end

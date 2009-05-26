class TriggerDetail < ActiveRecord::Base
  belongs_to :dealer
  has_many :qd_profiles
end

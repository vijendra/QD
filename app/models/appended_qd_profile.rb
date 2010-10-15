class AppendedQdProfile < ActiveRecord::Base
  belongs_to :data_append
  belongs_to :qd_profile
end

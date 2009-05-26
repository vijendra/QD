class Admin::TriggerDetailsController < ApplicationController
  layout 'admin'
  require_role 'super_admin'
  def index
    @triggers = TriggerDetail.all(:order => :created_at)
  end
end

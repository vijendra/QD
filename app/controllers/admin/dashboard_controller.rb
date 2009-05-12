class Admin::DashboardController < ApplicationController
  require_role :admin
  layout 'admin'
  
  def index
    redirect_to admin_dealers_url
  end
end

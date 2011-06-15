class Admin::DashboardController < ApplicationController
  before_filter :check_login
  require_role :admin
  layout 'admin'

  def index
    redirect_to admin_dealers_url
  end
end


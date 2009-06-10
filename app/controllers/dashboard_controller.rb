class DashboardController < ApplicationController
  # GET /
  # The default dashboard
  def index
    @home_page_content = AdminSetting.find_by_identifier('home_page_content').values rescue '<br /> Welcome to QD Robot.'
  end
end

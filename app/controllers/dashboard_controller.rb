class DashboardController < ApplicationController
  # GET /
  # The default dashboard
  def index
    @home_page_content = AdminSetting.find_by_identifier('home_text').values rescue '<br /> Welcome to QD Robot.'
  end
end

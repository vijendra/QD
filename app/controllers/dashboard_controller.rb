class DashboardController < ApplicationController

  def index
    @home_page_content = AdminSetting.find_by_identifier('home_page_content').value rescue '<br /> Welcome to QD Robot.'
  end
end

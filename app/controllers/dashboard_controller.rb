class DashboardController < ApplicationController

  def index
    @home_page_content = ApplicationSetting.find_by_identifier('home_page_content').value rescue '<br /> Welcome to QD Robot.'
    @seekernet_content = ApplicationSetting.find_by_identifier('seekerinc_process_instructions').value rescue '<br /> Seekerinc Process Instructions.'
    @transact_content = ApplicationSetting.find_by_identifier('tranzact_process_instructions').value rescue '<br /> Tranzact Process Instructions.'
  end
end

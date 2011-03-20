class DncNumber < ActiveRecord::Base
  $config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/database.yml'))
  self.establish_connection  $config["dnc_database"]
  
  def fetch_dnc_numbers(dealer)
    agent = WWW::Mechanize.new
    page = agent.get(trigger.file_url)
    login_form = page.forms[0]
    login_form.order_id = dealer.file_id
    login_form.order_pass = dealer.file_password
    page = agent.submit(login_form)
    
    agent.get(csv_link_string).save_as(File.join(ORDERS_DOWNLOAD_PATH, csv_file_name))
    dnc_csv = File.join(ORDERS_DOWNLOAD_PATH, csv_file_name)
    
    FasterCSV.foreach(orders_csv, :headers => :false) do |row|
      number = row.field('number')
      #mark the profile as dnd
      profile = dealer.qd_profiles.by_landline(number).first || dealer.qd_profiles.by_mobile(number).first
      profile.update_attribute('dnd', true) unless profile.blank?
      
      self.create(:number => row.field('number'), :dealer_id => dealer.id)
    end
  end
end

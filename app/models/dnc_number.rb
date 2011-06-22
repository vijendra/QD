class DncNumber < ActiveRecord::Base
  $config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/database.yml'))
  self.establish_connection  $config["dnc_database"]
  belongs_to :dealer
  require 'zip/zipfilesystem'

  def self.fetch_dnc_numbers(dealer)
    puts "xxxxxxxxxxxxxx"
    agent = WWW::Mechanize.new
    page = agent.get('https://telemarketing.donotcall.gov/login/login.aspx?ReturnUrl=%2fdownload%2fdnld.aspx')
    #First login form
    login_form = page.forms[0]

    login_form.field_with(:name => 'ctl00$MainContentPlaceHolder$ActNumberTextBox').value = dealer.profile.dnc_user_name
    login_form.field_with(:name => 'ctl00$MainContentPlaceHolder$ActPassTextBox').value = dealer.profile.dnc_password
    login_form.radiobutton_with(:value => 'DownloaderRoleRadioButton').check
    login_form.action = 'https://telemarketing.donotcall.gov/login/login.aspx?ReturnUrl=%2fdownload%2fdnld.aspx'
    certify_page = agent.submit(login_form, login_form.buttons.first)

    #Once logged in, asks for certify
    certify_form = certify_page.forms[0]
    certify_form.radiobutton_with(:value => 'YES').check
    certify_form.action = 'https://telemarketing.donotcall.gov/login/login.aspx?ReturnUrl=%2fdownload%2fdnld.aspx'
    agent.submit(certify_form, certify_form.buttons.first)

    #Once certified asks for clicking on full list of updates
    download_types_page = agent.get('https://telemarketing.donotcall.gov/download/dnldfull.aspx')
    download_types_form = download_types_page.forms[0]
    download_types_form.radiobutton_with(:value => 'txt').check
    download_page = agent.submit(download_types_form, download_types_form.buttons.first)

    download_links = download_page.links_with(:href => /dnldredrct.aspx/)
    unless download_links.blank?
      download_links.each do |link|
        download_dnc_files(link, dealer)
      end
    end
  end

  def self.send_dnc_in_week
    dealers = Dealer.dnc_for_week.all
    dealers.each do |dealer| DncNumber.fetch_dnc_numbers(dealer) end unless dealers.blank?
  end
  def self.send_dnc_twice_in_month
    dealers = Dealer.dnc_for_15_days.all
    dealers.each do |dealer| DncNumber.fetch_dnc_numbers(dealer) end unless dealers.blank?
  end
  def self.send_dnc_in_month
    dealers = Dealer.dnc_for_month.all
    dealers.each do |dealer| DncNumber.fetch_dnc_numbers(dealer) end unless dealers.blank?
  end

  protected

  def self.download_dnc_files(link, dealer)
    agent = WWW::Mechanize.new
    append_folder = "#{RAILS_ROOT}/data_appends"
    begin
      #When we click on download link, it redirects to new page, if the file is already downloaded once.
      #So we will construct the url like below, directly instead of handling such situations.
      #download link https://telemarketing.donotcall.gov/full/2011-3-27_24036554E44-EAB3-4167-B3BF-13E73EE57B8A.txt.zip
      base = "https://telemarketing.donotcall.gov/full/"
      file_num = "#{link.text}_#{link.href.gsub('dnldredrct.aspx?SetNm=', '').upcase}"
      file_link =  "#{base}#{Time.now.strftime('%Y-%m-%d').gsub('-0', '-')}_#{file_num}.txt.zip"
      target_file = "#{append_folder}/#{file_num}.txt"

      agent.get(file_link).save_as("#{target_file}.zip")

      zipped_order = File.join(append_folder, "#{file_num}.txt.zip")
      unzip_dnc_file(zipped_order, target_file)
      read_dnc_file(target_file, dealer)
    rescue Exception => e
      logger.error("Error downloading file: #{link}   #{e.to_s}")
    end
  end

  def self.unzip_dnc_file(zipped_order, file_name)
    begin
      #unzipping the order
      Zip::ZipFile.open(zipped_order) do |zip|
        dir = zip.dir
        dir.entries('.').each do |entry|
          zip.extract(entry, file_name) { true }
        end
      end
    rescue Exception => e
      log_error("Error unzipping file: #{zipped_order}  #{e.to_s}")
    end
  end

  def self.read_dnc_file(target_file, dealer)
    phone_numbers = ""
    File.new(target_file, "r").each do |number|
      phone_number = (number.sub /.+,/, '').gsub(/[\n]+/, ""); #extract 9919981 from 571,9919981/n
      qd_profile = dealer.qd_profiles.find(:first, :conditions => ['da_landline = ? OR mobile = ? OR compiled_landline = ?', phone_number, phone_number, phone_number])
      unless qd_profile.blank?
        qd_profile.update_attribute('dnc', true)
        DncNumber.create(:dealer_id => dealer.id, :number => phone_number )
      end
    end
  end

end


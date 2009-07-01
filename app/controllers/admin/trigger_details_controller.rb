class Admin::TriggerDetailsController < ApplicationController
  layout 'admin'
  require_role 'super_admin'
  require 'zip/zipfilesystem'
  require 'fastercsv'
  require 'fileutils'

  def index
    @search = TriggerDetail.new_search(params[:search])
    @search.per_page ||= 15
    @search.page ||= 1
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"

    @search.conditions.dealer.administrator_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')

    unless params[:today].blank?
      @search.conditions.created_at_after = Time.now.beginning_of_day()
       params[:today] = nil
    end

    unless params[:created_at].blank?
      date = Time.parse(params[:created_at])
      @search.conditions.created_at_after = date.beginning_of_day()
      @search.conditions.created_at_before =  date.end_of_day()
    end

    @triggers = @search.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealer }
      format.js {  render :update do |page|
      	            page.replace_html 'trigger-list', :partial => 'trigger_details_list'
     	           end
      	        }
    end
  end

  def process_triggers
    #TODO: Clean this code. Make the methods for distinct functions for example csv import, send_mail etc.
    search = TriggerDetail.new_search()
    search.conditions.dealer.administrator_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')
    search.conditions.status = 'unprocessed'
    triggers = search.all
    
    for trigger in triggers
      Dir.mkdir(File.join(ORDERS_DOWNLOAD_PATH)) unless File.exists?(File.join(ORDERS_DOWNLOAD_PATH))
      if trigger.data_source = 'seekerinc'
        #Logging in
        agent = WWW::Mechanize.new
        page = agent.get(trigger.file_url)
        login_form = page.forms[0]
        login_form.order_id = trigger.file_id
        login_form.order_pass = trigger.file_password
        page = agent.submit(login_form)

        #creating folders required extract file
        Dir.mkdir(File.join(ORDERS_DOWNLOAD_PATH, "#{dealer}_#{order_number}")) unless File.exists?(File.join(ORDERS_DOWNLOAD_PATH, "#{dealer}_#{order_number}"))
    
        #Downloading ZIP File
        confirm_form = page.forms[0]
        confirm_form.checkbox_with(:name => 'order_cbk').check
        zipped_order = File.join(ORDERS_DOWNLOAD_PATH, "#{dealer}_#{order_number}.zip")
        agent.submit(confirm_form).save_as(zipped_order)

        #unzipping the order
        Zip::ZipFile.open(zipped_order) do |zip|
          dir = zip.dir
          dir.entries('.').each do |entry|
            zip.extract(entry, File.join(ORDERS_DOWNLOAD_PATH , "#{dealer}_#{order_number}/#{entry}" ))
          end
        end

        #Find the CSV among all extracted files
        csvfiles = File.join(ORDERS_DOWNLOAD_PATH, "#{dealer}_#{order_number}", "*.csv")
        orders_csv = Dir.glob(csvfiles).first

        #import to the corresponding dealer
        dealer_profile = Profile.find_by_name(trigger.dealer_id)
        balance = trigger.balance - trigger.no_of_records.to_i
        
        
        data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
        FasterCSV.foreach(orders_csv, :headers => :false) do |row|
          data_set = {:dealer_id => dealer_profile.user_id, :trigger_detail_id => trigger.id}
          data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
          QdProfile.create(data_set)
        end

        dealer_profile.update_attribute('current_balance', balance )
        trigger.update_attribute('balance', balance )
        trigger.process!

        #delete the downloded folder
        FileUtils.rm_r zipped_order
        FileUtils.rm_r File.join(ORDERS_DOWNLOAD_PATH, "#{dealer}_#{order_number}")
        
        send_mail(dealer_profile.user, trigger.no_of_records, balance)

      elsif trigger.data_source = 'marketernet'
        agent = WWW::Mechanize.new
        page = agent.get(trigger.file_url)
        login_form = page.forms[0]
        login_form.username = 'ewatson@mailadvanta.com'
        login_form.password = 'a5$DOWNLOAD'
        login_form.checkbox_with(:name => 'saveagreement').check
        page = agent.submit(login_form)
         
        #extract order_id from link like 228_Courtesy Dodge_942310_322548.CSV
        csv_file_name = page.links[4].to_s
        object_id = (((csv_file_name.split('_'))[3]).split('.'))[0].strip
        
        #Now we will directly construct link, instead of mimicng csv link click, as its quite difficult
        csv_link_string = "https://intelidataexpress.marketernet.com/file/download.aspx?objectid=#{object_id}"   
        agent.get(csv_link_string).save_as(File.join(ORDERS_DOWNLOAD_PATH, csv_file_name))
     
        orders_csv = File.join(ORDERS_DOWNLOAD_PATH, csv_file_name)
      
      
        dealer_profile = Profile.find_by_user_id(trigger.dealer_id)
        balance =  trigger.balance - trigger.no_of_records.to_i
     
        field_list = ['lname', 'fname', 'mname', 'address', 'address2', 'city', 'state', 'zip',  'zip4', 'level', '', 'auto17', 'crrt', 'dpc', 'phone_num', 'pr01']
        FasterCSV.foreach(orders_csv, :headers => :false) do |row|
          data_set = {:dealer_id => trigger.dealer_id, :trigger_detail_id => trigger.id, :listid => "#{order_number}_#{row[10]}" }
          field_list.map {|f| data_set[f] = row[field_list.index(f)] unless f.blank?}
          QdProfile.create(data_set)
        end
        
        dealer_profile.update_attribute('current_balance', balance) 
        trigger.update_attribute('balance', balance )
        trigger.process!

        #delete the downloded folder
        FileUtils.rm_r orders_csv
         
        #sending mail with account information
        send_mail(dealer_profile.user, trigger.no_of_records, balance)
      end

    end

  end
  
  protected

  def send_mail(dealer, total, balance)
    dealer1 = Dealer.find(dealer)
    email = DealerMailer.create_dealer_accounts_notification(dealer1, total, balance)
    email.set_content_type("text/html" )
    DealerMailer.deliver(email)
  end
end

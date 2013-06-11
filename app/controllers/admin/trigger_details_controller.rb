class Admin::TriggerDetailsController < ApplicationController
  before_filter :check_login
  layout 'admin'
  require_role 'super_admin'
  require 'zip/zipfilesystem'
  require 'fastercsv'
  require 'fileutils'

  def index
    @search = TriggerDetail.new_search(params[:search])
    if params[:type] == "processed"
      @search.conditions.status = "processed"
      @type = "processed"
     else
       @type = "unprocessed"
       @search.conditions.status = "unprocessed"
    end

    @search.per_page  = 50
    @search.page ||= 1
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"
    @search.include = [:dealer]
    @search.conditions.dealer.administrator_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')

    unless params[:today].blank?
      @search.conditions.created_at_after = Time.now.beginning_of_day()
      params[:today] = nil
    end

    unless params[:created_at].blank?
      date = Time.parse(params[:created_at])
      @search.conditions.created_at_after = date.beginning_of_day()
      @search.conditions.created_at_before = date.end_of_day()
    end

    @triggers = @search.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @dealer }
      format.js { render :update do |page|
                    page.replace_html 'trigger-list', :partial => 'trigger_details_list'
                   end
       }
    end
  end

def process_triggers
  attachment = !params[:attachment].blank?
  #TODO: Clean this code. Make the methods for distinct functions for example csv import, send_mail etc.
  search = TriggerDetail.new_search()
  search.conditions.dealer.administrator_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')
  search.per_page = 5000
  search.conditions.status = 'unprocessed'
  triggers = search.all


  field_list = QdProfile::IMPORT_FILE_FIELDS

  Dir.mkdir(File.join(ORDERS_DOWNLOAD_PATH)) unless File.exists?(File.join(ORDERS_DOWNLOAD_PATH))
  for trigger in triggers
    dealer = trigger.dealer

    unless dealer.blank?
      dealer_profile = dealer.profile
      if trigger.total_records <= dealer_profile.current_balance && !trigger.file_url.blank?

        if trigger.data_source == 'seekerinc'
          #Logging in
          agent = WWW::Mechanize.new
          page = agent.get(trigger.file_url)
          login_form = page.forms[0]
          login_form.order_id = trigger.file_id
          login_form.order_pass = trigger.file_password
          page = agent.submit(login_form)

          #creating folders required to extract file
          Dir.mkdir(File.join(ORDERS_DOWNLOAD_PATH, "#{dealer.login}_#{trigger.order_number}")) unless File.exists?(File.join(ORDERS_DOWNLOAD_PATH, "#{dealer.login}_#{trigger.order_number}"))

          #Downloading ZIP File
          confirm_form = page.forms[0]
          confirm_form.checkbox_with(:name => 'order_cbk').check
          zipped_order = File.join(ORDERS_DOWNLOAD_PATH, "#{dealer.login}_#{trigger.order_number}.zip")
          agent.submit(confirm_form).save_as(zipped_order)

          #unzipping the order
          Zip::ZipFile.open(zipped_order) do |zip|
            dir = zip.dir
            dir.entries('.').each do |entry|
              zip.extract(entry, File.join(ORDERS_DOWNLOAD_PATH , "#{dealer.login}_#{trigger.order_number}/#{entry}" ))
            end
          end

          #Find the CSV among all extracted files
          csvfiles = File.join(ORDERS_DOWNLOAD_PATH, "#{dealer.login}_#{trigger.order_number}", "*.csv")
          orders_csv = Dir.glob(csvfiles).first

        elsif trigger.data_source == 'marketernet'
          agent = WWW::Mechanize.new
          page = agent.get(trigger.file_url)
          login_form = page.forms[0]

          datasource_password = dealer.administrator.administrator_profile.datasource_password rescue '' # datasource password
          datasource_username = dealer.administrator.administrator_profile.datasource_username rescue '' # datasource username
          login_form.username = datasource_username.blank?? 'ewatson' : datasource_username
          login_form.password = datasource_password.blank?? 'a6$DOWNLOAD' :  datasource_password

          login_form.checkbox_with(:name => 'saveagreement').check
          page = agent.submit(login_form)
          #extract order_id from link like 228_Courtesy Dodge_942310_322548.CSV
          links = page.links
          for li in links
            unless li.to_s =~ /FCRA/ #skip FCRA standard output file
              csv_file_name = li.to_s if li.to_s =~ /[0-9].CSV/
            end  
          end
          #csv_file_name = page.links[5].to_s
          csv_array = csv_file_name.to_s.split('_')
          object_id = ((csv_array[csv_array.length - 1]).split('.'))[0].strip
          #Now we will directly construct link, instead of mimicng csv link click, as its quite difficult
          csv_link_string = "https://intelidataexpress.tranzactis.com/file/download.aspx?objectid=#{object_id}"
=begin
          #Before tt was asking to login again. Now its working fine.
          page = agent.get(csv_link_string)
          login_form = page.forms[0]
          login_form.username = 'ewatson@mailadvanta.com'
          login_form.password = 'a5$DOWNLOAD'
          login_form.checkbox_with(:name => 'saveagreement').check
          file_page = agent.submit(login_form)
          agent.get(file_page.uri).save_as(File.join(ORDERS_DOWNLOAD_PATH, csv_file_name))
=end
          agent.get(csv_link_string).save_as(File.join(ORDERS_DOWNLOAD_PATH, csv_file_name))
          orders_csv = File.join(ORDERS_DOWNLOAD_PATH, csv_file_name)
        end
	      # import to the corresponding dealer
        balance = dealer_profile.current_balance - trigger.total_records.to_i
	      FasterCSV.foreach(orders_csv, :headers => :false) do |row|
	        data_set = {:dealer_id => trigger.dealer_id, :trigger_detail_id => trigger.id }
	        row.each do |col|
	          data_set[field_list[col.first]] = col.second unless col.first == 'ORDERRECORDID' unless field_list[col.first].blank?
	        end
          data_set['listid'] = "#{trigger.order_number}_#{row.field('ORDERRECORDID')}" if trigger.data_source == 'marketernet'
	        QdProfile.create(data_set)
        end
      	dealer_profile.update_attribute('current_balance', balance)
        trigger.update_attribute('balance', balance )
        trigger.make_processed(current_user.id)

	      #generate masked csv to be attached to the dealer's mail
        generate_csv_file(trigger, dealer_profile)

        #sending mail with account information
        send_mail(dealer_profile, trigger.total_records, balance, trigger.order_number, attachment)

      	#delete the downloded folder
      	if trigger.data_source == 'seekerinc'
	        FileUtils.rm_r zipped_order
          FileUtils.rm_r File.join(ORDERS_DOWNLOAD_PATH, "#{dealer.login}_#{trigger.order_number}")
	      else
	        FileUtils.rm_r orders_csv
	      end

      end # if condition
    end # unless condition
  end #for loop

   #Now all the export is over. Just remove the content from temp csv we used
   FasterCSV.open("#{RAILS_ROOT}/public/file.csv", "w") do |csv|
     csv << []
   end
   flash[:notice] = "All pending triggers are successfully processed."
   redirect_to(admin_trigger_details_url)
 end

  def mark_processed
    trigger = TriggerDetail.find(params[:id])
    trigger.process!
    flash[:notice] = "Selected trigger is successfully marked as rocessed."
    redirect_to(admin_trigger_details_url)
  end

  protected

  def send_mail(dealer_profile, total, balance, order, attachment)
     DealerMailer.deliver_dealer_accounts_notification(dealer_profile, total, balance, order, attachment)
  end

  def generate_csv_file(trigger, dealer_profile)
    dealer = dealer_profile.user
    qd_profiles = trigger.qd_profiles
    fields_to_be_shown = dealer.dealer_field.fields.sort rescue QdProfile.public_attributes

    FasterCSV.open("#{RAILS_ROOT}/public/file.csv", "w") do |csv|
      #Exporting to CSV starts here.. Exporting headers
      csv << fields_to_be_shown.map{|field| field.humanize}

      #Exporting data rows
      qd_profiles.each do |prof|
         csv << fields_to_be_shown.map{|qd_field| eval("prof.#{qd_field}")}
      end
    end
  end

end


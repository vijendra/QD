class DataAppend < ActiveRecord::Base
  require 'net/ftp'
  require 'fileutils'

  attr_accessor :tid_list, :product_types, :profile_ids
  after_create :send_for_append

  validates_presence_of :tid
  validates_presence_of :product

  belongs_to :dealer
  belongs_to :requestor, :class_name => 'User', :foreign_key => :requestor_id
  has_many :appended_qd_profiles
  has_many :qd_profiles, :through => :appended_qd_profiles

  named_scope :pending_ncoa_appends, {:conditions => ["status_message = ? AND product = ?", 'pending', 'ncoa'] }


  AppendProducts = [['Append type', ''], ['Phone', 'ph'], ['Email', 'em'], ['NCOA', 'ncoa']]
  AppendXmlProduct = {'ph' => 'AppendPhoneAllToNameAddress',  'em' => 'AppendEmailToNameAddress', 'ncoa' => 'AppendNcoaToNameAddress' }
  AppendProductDisplay = {'ph' => 'Phone', 'em' => 'Email', 'ncoa' => 'NCOA'}


=begin
  def send_each_trigger_for_append
    tid_list.each do |tid|
      send_for_append(tid)
    end
  end
=end
  def send_for_append
    if self.product == "ncoa"
      send_for_ncoa_append
    else
      send_for_other_appends
    end
  end

  def send_for_ncoa_append
    dummy_file = "#{RAILS_ROOT}/data_appends/dummy_records.csv"
    trigger = TriggerDetail.find(tid)
    unless trigger.blank?
      csv_file = construct_csv(trigger)
      if trigger.total_records < 100
        #NCOA needs min 100 records to process. So append some dummy records.
        FasterCSV.open(csv_file, "a") do |csv|
          FasterCSV.foreach(dummy_file, :headers => :false) do |row|
            csv << row
          end
        end
      end

      # Open FTP connection. Change to "in" folder. Upload files. Quit the connection
      begin
        ftp = ftp_connection('btobinnovations.com', 'admin', 'watson01', 2111)
        ftp.chdir('in')
    	  ftp.put(csv_file)
        ftp.quit()
      rescue Errno::ETIMEDOUT
        self.errors.add_to_base 'Append service is down. Please try after some time.'
      rescue SystemCallError
        self.errors.add_to_base 'Something went wrong. Please try after some time'
      rescue => e
        return false
      end

      # Schedule listening for appended data
      self.send_at(5.minutes.from_now, :listen_to_append)
      #update file name in append record
      self.update_attribute('csv_file_name', csv_file.gsub("#{RAILS_ROOT}/data_appends/data_append_in/", '') )
      remove_file(csv_file)
    end
  end

  def send_for_other_appends
    unless tid.blank?
      trigger = TriggerDetail.find(tid)
      unless trigger.blank?
        csv_file = construct_csv(trigger)
        xml_file = construct_xml(csv_file)

        # Open FTP connection. Change to "in" folder. Upload files. Quit the connection
        begin
          ftp = ftp_connection('ftp.accurateappend.com', 'b2binnovations', 'innovator')
          ftp.chdir('in')
    	    ftp.put(csv_file)
          ftp.put(xml_file)
          ftp.quit()
        rescue Errno::ETIMEDOUT
          self.errors.add_to_base 'Append service is down. Please try after some time.'
        rescue SystemCallError
          self.errors.add_to_base 'Something went wrong. Please try after some time'
        rescue => e
          return false
        end

        # Schedule listening for appended data
        self.send_at(5.minutes.from_now, :listen_to_append)
        #update file name in append record
        self.update_attribute('csv_file_name', csv_file.gsub("#{RAILS_ROOT}/data_appends/data_append_in/", '') )
        remove_file(csv_file)
        remove_file(xml_file)
      end
    end
  end

  def ftp_connection(ftp_server, username, password, port=21)
    ftp = Net::FTP.new
    ftp.connect(ftp_server, port)
    ftp.login(username, password)
    ftp.passive = true
    return ftp
  end

  #Constructing the csv file to be sent for append
  def construct_csv(trigger)
    identifier = "#{self.dealer_id}-#{Time.now.strftime('%H%M%S')}-#{self.product}.csv"
    csv_file = "#{RAILS_ROOT}/data_appends/data_append_in/#{identifier}"
    fields  = QdProfile::DATA_APPEND_FIELDS
    FasterCSV.open(csv_file, "w") do |csv|
      csv << QdProfile::DATA_APPEND_HEADERS
      #Exporting data rows
      trigger.qd_profiles.each do |qd_profile|
        csv << QdProfile::DATA_APPEND_HEADERS.map{|key| eval("qd_profile.#{fields[key]}")}
      end
    end
    return csv_file
  end

  #Constructing xml file to be sent for append
  def construct_xml(csv_file_name)
    xml_file_name =  "#{csv_file_name}.manifest.xml"
    product = DataAppend::AppendXmlProduct[self.product]
    columnmap = 'Unknown;FirstName;LastName;StreetAddress;City;State;PostalCode;'

    xml_file = File.new(xml_file_name, "a")
    xml_file.puts('<?xml version="1.0" encoding="utf-8"?>')
    #builder = Builder::XmlMarkup.new(:target => xml_file, :ident=>2)
    builder = Builder::XmlMarkup.new(:ident => 2)
    data = builder.file{|f| f.name(csv_file_name); f.product(product); f.columnmap(columnmap)}
    data.gsub('<inspect />', '')
    xml_file.puts(data)
    xml_file.close
    return xml_file_name
  end

  def listen_to_append
    begin
      found = false
      csv_file = self.csv_file_name
      out_file = "#{RAILS_ROOT}/data_appends/data_append_out/#{csv_file}"
      if self.product == 'ncoa'
        ftp = ftp_connection('btobinnovations.com', 'admin', 'watson01', 2111)
      else
        ftp = ftp_connection('ftp.accurateappend.com', 'b2binnovations', 'innovator')
      end

      ftp.chdir('out')
      unless self.product == 'ncoa'
        ftp.list('*.csv').each do |file|
          if file =~ Regexp.new(csv_file)
            found = true
            ftp.getbinaryfile(csv_file, out_file)
            import_appended_data
            ftp.getbinaryfile("#{csv_file}.manifest.xml", "#{out_file}.manifest.xml")
            parse_output_xml("#{out_file}.manifest.xml")
          end
        end
      else
        file_name = csv_file.gsub('.csv','') # file name
        ftp.dir.each do |di|
          if di =~ Regexp.new("#{file_name.upcase} *")
             folder = di.split('<DIR>').last.lstrip
             ftp.chdir("#{folder}")
             ftp.getbinaryfile("#{file_name}-processed.csv", out_file)
             import_appended_data
             found = true
             break;
           end
        end
      end
      ftp.quit()

      if found == false
        raise "Not yet processed"
      else
        self.update_attribute('status_message', 'appended')
        DealerMailer.deliver_append_details(self)
      end

    #rescue Net::FTPPermError => e
      #schedule it again after 10 minutes
      #self.send_at(10.minutes.from_now, :listen_to_append)
    end
  end

  def parse_output_xml(xml_report)
    xml = File.read(xml_report)
    doc = Hpricot::XML(xml)
    self.update_attributes(:matches => (doc/:matches).inner_html, :total_errors => (doc/:errors).inner_html,
                           :completed_on => Time.parse((doc/:datecomplete).inner_html) )
    remove_file(xml_report)
  end

  def import_appended_data
    csv_file = "#{RAILS_ROOT}/data_appends/data_append_out/#{self.csv_file_name}"
    trigger = TriggerDetail.find(self.tid)
    
    FasterCSV.foreach(csv_file, :headers => :false) do |row|
      qd_profile = trigger.qd_profiles.find(row.field(0))  rescue next #row.field(0) is ID
      unless qd_profile.blank?
        self.appended_qd_profiles.create(:qd_profile_id => qd_profile.id)
        case self.product
        when 'ph' then
          qd_profile.update_attribute('compiled_landline', row.field('Compiled Land Line'))
          qd_profile.update_attribute('da_landline', row.field('DA Land Line'))
          qd_profile.update_attribute('mobile', row.field('Mobile'))
        when 'em' then qd_profile.update_attribute('email', row.field('EmailAddress'))
        when 'ncoa' then
          qd_profile.update_attributes('address' => row.field('address'), 'city' => row.field('city'), 'state' =>  row.field('st'), 'zip' => row.field('zip')) # changed state to st
          self.update_attributes(:completed_on => Time.now)
        end
      end
    end
    
    if self.product == 'ph'
      DataAppend.check_profile_for_dnc(tid) # check profile for dnc number present
    end
    
    remove_file(csv_file)
  end

  def self.check_profile_for_dnc(tid)
    qd_profiles = TriggerDetail.find(tid).qd_profiles rescue []
    qd_profiles.each do |profile|
      value = []
      value << profile.da_landline if profile.da_landline
      value << profile.mobile if profile.mobile
      value << profile.compiled_landline if profile.compiled_landline
      profile.update_attribute('dnc', true) if DncNumber.by_number(value).first
    end
  end

  def remove_file(file)
    FileUtils.rm_r file
  end
end


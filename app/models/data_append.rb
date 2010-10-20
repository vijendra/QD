class DataAppend < ActiveRecord::Base
  require 'net/ftp'
  require 'fileutils'
  
  attr_accessor :tid, :profile_ids
  after_create :send_for_append
  
  belongs_to :dealer
  belongs_to :requestor, :class_name => 'User', :foreign_key => :requestor_id
  has_many :appended_qd_profiles
  has_many :qd_profiles, :through => :appended_qd_profiles
  AppendProducts = [['Append type', ''], ['Landline', 'll'], ['Mobile', 'mb'], ['Mobile & Landline', 'ml'], ['Email', 'em']]
  
  AppendXmlProduct = {'ll' => 'AppendPhoneToNameAddress_LandLine', 'mb' => 'AppendPhoneToNameAddress_CellLine', 'ml' => 'AppendPhoneToNameAddress_Composite', 'em' => 'AppendEmailToNameAddress'} 
  
  AppendProductDisplay = {'ll' => 'Landline', 'mb' => 'Mobile', 'ml' => 'Mobile & Landline', 'em' => 'Email'}
  
  
  #TODO try to move this into some library
  def send_for_append
    unless tid.blank?
      trigger = TriggerDetail.find(tid)
      dealer = trigger.dealer
      #construct the csv and xml files and open them for writing
      fname = "#{dealer.id}-#{dealer.login}-#{Time.now.strftime('%d%M%Y')}-#{Time.now.strftime('%H%M')}.csv"
      csv_file = "#{RAILS_ROOT}/data_append_in/#{fname}"
      xml_file =  "#{RAILS_ROOT}/data_append_in/#{fname}.manifest.xml"
      
      File.new(csv_file, "w")
                 
      unless trigger.blank?
        qd_profiles = trigger.qd_profiles
        fields  = QdProfile::DATA_APPEND_FIELDS
        headers = QdProfile:: DATA_APPEND_HEADERS
        FasterCSV.open(csv_file, "w") do |csv|
          #Exporting to CSV starts here.. Exporting headers
          csv << headers.map{|field| field}
 
          #Exporting data rows
          qd_profiles.each do |prof|
            csv << headers.map{|key| eval("prof.#{fields[key]}")}
          end
        end
        
        construct_xml(xml_file)
        
        self.update_attribute('csv_file_name', fname)
                
        #Now send the file for append thru FTP
        #TODO move this to delayed job.
        #----------------------------------------------------------------------------
      
        begin
          ftp = Net::FTP.new('ftp.accurateappend.com')
          ftp.login('b2binnovations', 'innovator')
          ftp.passive = true
          
          #logged in, ready to start copying files..."
          ftp.chdir('in')
  
          #"uploading file s
    	    ftp.put(csv_file)
          ftp.put(xml_file)
          
          #Quit the connection
          ftp.quit()
  
          #update file name in the data append object
          self.update_attribute('csv_file_name', fname)
          
          #schedule listening for appended data
          self.send_at(10.minutes.from_now, :listen_to_append)
          
          FileUtils.rm_r csv_file
          FileUtils.rm_r xml_file
          
        rescue Errno::ETIMEDOUT
          self.errors.add_to_base 'Seems append service is down. Please try after some time.'
        rescue SystemCallError
          self.errors.add_to_base 'Something went wrong. Please try after some time'
        rescue Net::FTPPermError => e
          #puts "Failed: #{e.message}"
          return false
        end
        #----------------------------------------------------------------------------
       
      end
    end  
  end

  def listen_to_append
    begin
      found = false
      fname = self.csv_file_name
      out_file = "#{RAILS_ROOT}/data_append_out/#{fname}"
          
      ftp = Net::FTP.new('ftp.accurateappend.com')
      ftp.login('b2binnovations', 'innovator')
      ftp.passive = true
      #logged in, ready to check files
      ftp.chdir('out')
 
      ftp.list('*.csv').each do |file|
        if file =~ Regexp.new(fname)
          found = true
          ftp.getbinaryfile(fname, out_file)
          ftp.getbinaryfile("#{fname}.manifest.xml", "#{out_file}.manifest.xml")
          import_appended_data
          parse_output_xml("#{out_file}.manifest.xml")
        end  
      end
      #Quit the connection
      ftp.quit()
  
      if found == false
        #schedule it again after 10 minutes
        self.send_at(10.minutes.from_now, :listen_to_append)
      else
        #update status in the data_append object
        self.update_attribute('status_message', 'appended')  
      end
          
    rescue Net::FTPPermError => e
      #schedule it again after 10 minutes
      self.send_at(10.minutes.from_now, :listen_to_append)
    end
  end
 
  def parse_output_xml(xml_report)
    xml = File.read(xml_report)
    doc = Hpricot::XML(xml)
    self.update_attributes(:matches => (doc/:matches).inner_html, :total_errors => (doc/:errors).inner_html, :completed_on => Time.parse((doc/:datecomplete).inner_html) )
    FileUtils.rm_r xml_report
  end
  
  def import_appended_data
    csv_file = "#{RAILS_ROOT}/data_append_out/#{self.csv_file_name}"
    FasterCSV.foreach(csv_file, :headers => :false) do |row|
      qd_profile = QdProfile.find(row.field(0)) #row.field(0) is ID
      unless qd_profile.blank?
        self.appended_qd_profiles.create(:qd_profile_id => qd_profile.id) 
        qd_profile.update_attribute('appended_landline', row.field('Land Line'))
      end   
    end
    FileUtils.rm_r csv_file
  end
  
  def construct_xml(filename)
    product = DataAppend::AppendXmlProduct[self.product]
    columnmap = 'Unknown;FirstName;LastName;StreetAddress;City;State;PostalCode;'
    
    xml_file = File.new(filename, "a")
    xml_file.puts('<?xml version="1.0" encoding="utf-8"?>')
    #builder = Builder::XmlMarkup.new(:target => xml_file, :ident=>2)
    builder = Builder::XmlMarkup.new(:ident=>2)
    data = builder.file{|f| f.name(filename); f.product(product); f.columnmap(columnmap)}
    data.gsub('<inspect />', '')
    xml_file.puts(data)
    xml_file.close
  end
end

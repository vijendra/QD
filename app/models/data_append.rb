class DataAppend < ActiveRecord::Base
  require 'net/ftp'
  require 'fileutils'
  
  attr_accessor :tid, :profile_ids
  after_create :send_for_append
  
  belongs_to :dealer
  belongs_to :requestor, :class_name => 'User', :foreign_key => :requestor_id

  #TODO try to move this into some library
  def send_for_append
    unless tid.blank?
      trigger = TriggerDetail.find(tid)
      dealer = trigger.dealer
      #construct the csv file name and open it for writing
      fname = "#{dealer.id}-#{dealer.login}-#{Time.now.strftime('%d%M%Y')}-#{Time.now.strftime('%H%M')}.csv"
      csv_file = "#{RAILS_ROOT}/data_append_in/#{fname}"
      File.new(csv_file, "w")
      
      unless trigger.blank?
        qd_profiles = trigger.qd_profiles
        fields_to_be_exported = QdProfile::DATA_APPEND_FIELDS
        FasterCSV.open(csv_file, "w") do |csv|
          #Exporting to CSV starts here.. Exporting headers
          csv << fields_to_be_exported.map{|field| field.humanize}
 
          #Exporting data rows
          qd_profiles.each do |prof|
            csv << fields_to_be_exported.map{|qd_field| eval("prof.#{qd_field}")}
          end
        end
        self.update_attribute('csv_file_name', fname)
        self.update_attribute('status_message', "Data is sent for append.")
 
        #Now send the file for append thru FTP
        #TODO move this to delayed job.
        #----------------------------------------------------------------------------
        
        begin
          ftp = Net::FTP.new('ftp.accurateappend.com')
          ftp.login('b2binnovations', 'innovator')
          ftp.passive = true
          #logged in, ready to start copying files..."
          ftp.chdir('in')
  
 			    #csv_files = Dir.glob("#{RAILS_ROOT}/data_append/*.csv")   
  			  #csv_files.each do |file|
   		      #"uploading file 
    	      ftp.put(csv_file)
          #end
          
          #Quit the connection
          ftp.quit()
  
          #update file name in the data append object
          self.update_attribute('csv_file_name', fname)
          
          #schedule listening for appended data
          self.send_at(10.minutes.from_now, :listen_to_append)
          
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
        end  
      end
      #Quit the connection
      ftp.quit()
  
      if found == false
        #schedule it again after 10 minutes
        self.send_at(10.minutes.from_now, :listen_to_append)
      else
        #update status in the data_append object
        self.update_attribute('status_message', 'Data appended. No of phone number appended records: ')  
      end
          
      rescue Net::FTPPermError => e
        puts "Failed: #{e.message}"
        return false
      end
  
  end
 
  
end

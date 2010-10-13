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
      fname = "#{dealer.id}#{dealer.login}#{Time.now.strftime("%d%m%Y%H%M")}.csv"
      csv_file = "#{RAILS_ROOT}/data_append_in/#{fname}"
      File.new(csv_file, "w")
      
      unless trigger.blank?
        qd_profiles = trigger.qd_profiles
        fields_to_be_exported = QdProfile.public_attributes
        FasterCSV.open(csv_file, "w") do |csv|
          #Exporting to CSV starts here.. Exporting headers
          csv << fields_to_be_exported.map{|field| field.humanize}
 
          #Exporting data rows
          qd_profiles.each do |prof|
            csv << fields_to_be_exported.map{|qd_field| eval("prof.#{qd_field}")}
          end
        end
        self.update_attribute('csv_file_name', fname)
        #self.send_at(1.minutes.from_now, :listen_to_append)
        self.listen_to_append
        #Now send the file for append thru FTP
        #TODO move this to delayed job.
        #----------------------------------------------------------------------------
=begin        
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
          self.listen_to_append
          
        rescue Net::FTPPermError => e
          #puts "Failed: #{e.message}"
          return false
        end
        #----------------------------------------------------------------------------
=end        
      end
    end  
  end


  def listen_to_append
    begin
      found = false
      csv_file = "#{RAILS_ROOT}/data_append_out/#{self.csv_file_name}"
      
      ftp = Net::FTP.new('ftp.accurateappend.com')
      ftp.login('b2binnovations', 'innovator')
      ftp.passive = true
      #logged in, ready to check files
      ftp.chdir('out')
      
      ftp.list('*.csv').each do |file|
        if file == self.csv_file_name
          found = true
          ftp.get(file, File.basename(csv_file))
        end  
      end
      #Quit the connection
      ftp.quit()
  
 
      #Delayed job will run again after some time if there is an error   
      if found == false
        raise "error: file is not yet in out file"
      else
        #update status in the data_append object
        self.update_attribute('status_message', 'Data appended succssfully')  
      end
          
      rescue Net::FTPPermError => e
        #puts "Failed: #{e.message}"
        return false
      end
  
  end
  
  #handle_asynchronously :listen_to_append, :run_at => Proc.new { 1.minutes.from_now.getutc}
  
end

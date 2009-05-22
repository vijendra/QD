class MailProcessor < ActionMailer::Base
  require 'hpricot'
  require 'mechanize'
  require 'zip/zipfilesystem'
  require 'fastercsv'

  def receive(mail)
    Dir.mkdir(File.join(ORDERS_DOWNLOAD_PATH)) unless File.exists?(File.join(ORDERS_DOWNLOAD_PATH))
    parser = Hpricot.parse(mail.body)
=begin
    #if (mail.from.to_s =~ /@seekerinc.com/) 
    #Parsing mail to get required information
    
    dealer = parser.search("tr")[1].search("td")[1].at("p").inner_html.strip
    table_rows = parser.search("tr")
    order_number = table_rows[7].search("td")[1].at("p").inner_html.strip
    file_id = table_rows[8].search("td")[1].at("p").inner_html
    password = table_rows[9].search("td")[1].at("p").inner_html
    file_url = table_rows[10].search("td")[1].at("p").at("a").inner_html

    #Logging in
    agent = WWW::Mechanize.new
    page = agent.get(file_url)
    login_form = page.forms[0]
    login_form.order_id = file_id
    login_form.order_pass = password
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
   dealer_profile = Profile.find_by_name(dealer)
   balance = dealer_profile.current_balance

    data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(orders_csv, :headers => :false) do |row|
      balance = balance -1
      data_set = {:dealer_id => dealer_profile.user_id}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end

    dealer_profile.update_attribute('current_balance', balance)
    end
=end
  #else
    dealer_id = parser.search("table").search("table")[2].at("tr").search("td")[1].at("p").at("span").inner_html.strip
    no_of_records = parser.search("table").search("table")[2].search("tr")[3].search("td")[1].at("p").at("span").inner_html.strip
    file_url = parser.search("table").search("table")[2].search("tr")[4].at("td").at("p").at("b").at("span").at("a").attributes['href']
    order_id = URI.split(file_url)[7].split("=")[1].strip
  
    agent = WWW::Mechanize.new
    page = agent.get(file_url)
    login_form = page.forms[0]
    login_form.username = 'ewatson@mailadvanta.com'
    login_form.password = 'a5$DOWNLOAD'
    login_form.checkbox_with(:name => 'saveagreement').check
    page = agent.submit(login_form)
         
    #extract order_id from link like 228_Courtesy Dodge_942310_322548.CSV
    csv_file_name = page.links[4].to_s
    object_id = (((csv_file_name.split('_'))[3]).split('.'))[0].strip

    #Now we will directly construct link, instead of mimicng csv link click, as its quite difficult.
    csv_link_string = "https://intelidataexpress.marketernet.com/file/download.aspx?objectid=#{object_id}"   
    agent.get(csv_link_string).save_as(File.join(ORDERS_DOWNLOAD_PATH, csv_file_name))
     
    dealer_profile = Profile.find_by_name(dealer)
    balance = dealer_profile.current_balance

    data_source2 = ['listid', 'lname', 'fname', 'mname', 'suffix', 'address', 'address2', 'city', 'state', 'zip',  'zip4', 'level', '', 'auto17', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(orders_csv, :headers => :false) do |row|
      balance = balance -1
      data_set = {:dealer_id => dealer_id}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end

    dealer_profile.update_attribute('current_balance', balance) 

  end

end

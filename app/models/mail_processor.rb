class MailProcessor < ActionMailer::Base
  require 'hpricot'
  require 'mechanize'
  
  def receive(mail)
    parser = Hpricot.parse(mail.body)
    #Parsing mail to get required information
    if (mail.from.to_s =~ /@seekerinc.com/ || mail.subject.to_s =~ /File Download Instructions/) 
      table_rows = parser.search("tr")
      dealer = table_rows[1].search("td")[1].inner_text.strip
      no_of_records = table_rows[4].search("td")[1].inner_text.strip
      order_number = table_rows[7].search("td")[1].inner_text.strip
      file_id = table_rows[8].search("td")[1].inner_text.strip
      password = table_rows[9].search("td")[1].inner_text.strip
      file_url = table_rows[10].search("td")[1].inner_text.strip     

      if TriggerDetail.find_by_order_number(order_number).blank? 
        dealer_profile = Profile.find_by_name(dealer)
        TriggerDetail.create(:dealer_id => dealer_profile.user_id, :data_source => 'seekerinc', :total_records => no_of_records, :order_number => order_number, :balance => dealer_profile.current_balance, :file_id => file_id, :file_password => password, :file_url => file_url ) unless dealer_profile.blank?
      end   
    end

    if (mail.from.to_s =~ /@tranzactis.com/ || mail.subject =~ /Order Fulfillment Notification/) 
      dealer_id = parser.search("table").search("table")[2].at("tr").search("td")[1].inner_text.strip
      no_of_records = parser.search("table").search("table")[2].search("tr")[3].search("td")[1].inner_text.strip
      file_url = parser.search("table").search("table")[2].search("tr")[4].at("td").at("p").at("b").at("span").at("a").attributes['href']
      order_number = file_url.split('/')[5].strip

      if TriggerDetail.find_by_order_number(order_number).blank?
        dealer_profile = Profile.find_by_user_id(dealer_id)
        TriggerDetail.create(:dealer_id => dealer_id, :data_source => 'marketernet', :total_records => no_of_records, :order_number => order_number, :balance => dealer_profile.current_balance, :file_url => file_url ) unless dealer_profile.blank?
      end  
    end 
    
  end
  
 
end

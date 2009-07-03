class DealerMailer < ActionMailer::Base
  

  def active_dealer_mail(dealer, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealer.email
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    content_type  "text/html"
    body       :dealer => dealer, :body_content => body_content
  end

  def inactive_dealer_mail(dealer, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealer.email
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    content_type  "text/html"
    body       :dealer => dealer, :body_content => body_content
  end
  
  def admin_mail(admin, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients admin.email
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    content_type  "text/html"
    body       :admin => admin, :body_content => body_content
  end

  def dealer_accounts_notification(dealer, total, balance, csv_path, order)
    subject    "[#{configatron.site_name}] " + 'Accounts information'
    recipients dealer.email
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
   
    content_type  "multipart/alternative"

    part :content_type => "text/html", :body => render_message('dealer_accounts_notification', :dealer => dealer, :total => total, :balance => balance) 

    attachment "text/csv" do |a|  
      a.body =  File.read(csv_path)
      a.filename = "#{order}.csv"
    end
  end
end

class DealerMailer < ActionMailer::Base

  def append_details(data_append)
    subject    "[#{configatron.site_name}] Append Details"
    recipients "#{data_append.dealer.email}, #{data_append.dealer.administrator.email}"
    from       configatron.support_email
    reply_to   "#{configatron.support_email}"
    sent_on    Time.now
    content_type  "text/html"
    body       :data_append => data_append, :site_name => configatron.site_name
  end

  def active_dealer_mail(dealer, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealer.email
    from       configatron.support_email
    reply_to   "#{configatron.support_email}"
    sent_on    Time.now
    content_type  "text/html"
    body       :dealer => dealer, :body_content => body_content
  end

  def inactive_dealer_mail(dealer, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealer.email
    reply_to   "#{configatron.support_email}"
    from       "#{configatron.support_email}"
    sent_on    Time.now
    content_type  "text/html"
    body       :dealer => dealer, :body_content => body_content
  end

  def admin_mail(admin, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients admin.email
    reply_to   "#{configatron.support_email}"
    from       "#{configatron.support_email}"
    sent_on    Time.now
    content_type  "text/html"
    body       :admin => admin, :body_content => body_content
  end

   def dealer_accounts_notification(dealer_profile, total, balance, order, attachment)
    subject    "[#{configatron.site_name}] " + 'Accounts information'
    recipients [dealer_profile.user.email] + dealer_profile.emails_extra.split(';')
    from       configatron.support_email
    sent_on    Time.now
    reply_to   [configatron.support_email]
    content_type  "multipart/alternative"
    part :content_type => 'text/plain',
         :body => render_message('dealer_accounts_notification_plain', :dealer_profile => dealer_profile, :total => total, :balance => balance, :order => order)

    part :content_type => "text/html", :body => render_message('dealer_accounts_notification_html', :dealer_profile => dealer_profile, :total => total, :balance => balance, :order => order)
    if attachment
      attachment "text/csv" do |a|
        a.body =  File.read("#{RAILS_ROOT}/public/file.csv")
        a.filename = "#{order}.csv"
      end
    end
  end
end


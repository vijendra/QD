class DealerMailer < ActionMailer::Base
  

  def active_dealer_mail(dealers, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealers.values
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    body       :dealers => dealers.keys, :body_content => body_content
  end

  def inactive_dealer_mail(dealers, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients dealers.values
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    body       :dealers => dealers.keys, :body_content => body_content
  end
  
  def admin_mail(admins, body_content, subject)
    subject    "[#{configatron.site_name}] " + subject
    recipients admins.values
    from       "#{configatron.support_name} <#{configatron.support_email}>"
    sent_on    Time.now
    body       :dealers => admins.keys, :body_content => body_content
  end

end

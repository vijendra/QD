class Admin::RobotsController < ApplicationController
  require 'mechanize'
  #require File.dirname(__FILE__) + '/../config/environment.rb'

  #require_role 'super_admin'
  layout 'admin'
  
  def run
    @config = YAML.load_file("#{RAILS_ROOT}/config/mail.yml")
    @config = @config[RAILS_ENV].to_options
    @fetcher = Fetcher.create({:receiver => MailProcessor}.merge(@config))
    @fetcher.fetch
    flash[:notice] = 'CSV data is successfully imported.'

    redirect_to(admin_trigger_details_url)
  end

  def active_dealer_email
    dealers = {}
    Dealer.active_dealers.map{|dealer| dealers[dealer.id] = dealer.email}
    body_content = AdminSetting.find_by_identifier('active_dealer_email').value rescue 'Active dealer mail body content.'
    subject = AdminSetting.find_by_identifier('active_dealer_email_subject').value rescue 'Active dealer mail subject content.'
    
    email = DealerMailer.create_active_dealer_mail(dealers, body_content, subject)
    email.set_content_type("text/html" )
    DealerMailer.deliver(email)
 
    flash[:notice] = "Mail is succssfully sent to all active dealers."
    redirect_to(admin_user_path(params[:id]))
  end

  def active_dealer_email
    dealers = {}
    Dealer.inactive_dealers.map{|dealer| dealers[dealer.id] = dealer.email}
    body_content = AdminSetting.find_by_identifier('inactive_dealer_email').value rescue 'Inctive dealer mail body content.'
    subject = AdminSetting.find_by_identifier('inactive_dealer_email_subject').value rescue 'Inctive dealer mail subject content.'
    
    email = DealerMailer.inactive_active_dealer_mail(dealers, body_content, subject)
    email.set_content_type("text/html" )
    DealerMailer.deliver(email)
 
    flash[:notice] = "Mail is succssfully sent to all inactive dealers."
    redirect_to(admin_user_path(params[:id]))
  end

  def admin_email
    admins = {}
    Administrator.all.map{|admin| admins[admin.id] = admin.email}
    body_content = AdminSetting.find_by_identifier('admin_email').value rescue 'Administrators mail body content.'
    subject = AdminSetting.find_by_identifier('admin_email_subject').value rescue 'Administrators mail subject content.'
    
    email = DealerMailer.create_admin_mail(admins, body_content, subject)
    email.set_content_type("text/html" )
    DealerMailer.deliver(email)
 
    flash[:notice] = "Mail is succssfully sent to all administrators."
    redirect_to(admin_user_path(params[:id]))
  end
end

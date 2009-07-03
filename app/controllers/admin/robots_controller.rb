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
  	unless params[:ad].blank?
  		administrator = Administrator.find(params[:ad])
      dealers = administrator.dealers.active_dealers
      body_content = AdministratorSetting.by_administrator_and_identifier(administrator.id,'active_dealer_email').value rescue 'Active dealer mail body content.'
      subject = AdministratorSetting.by_administrator_and_identifier(administrator.id,'active_dealer_email_subject').value rescue 'Active dealer mail subject content.'

	  else
      dealers = Dealer.active_dealers
      body_content = ApplicationSetting.find_by_identifier('active_dealer_email').value rescue 'Active dealer mail body content.'
      subject = ApplicationSetting.find_by_identifier('active_dealer_email_subject').value rescue 'Active dealer mail subject content.'
   end

    for dealer in dealers
       email = DealerMailer.deliver_active_dealer_mail(dealer, body_content, subject)
    end
    flash[:notice] = "Mail is succssfully sent to all active dealers."

    params[:ad].blank? ? redirect_to(admin_user_path(params[:id])) :  redirect_to(edit_admin_administrator_url(administrator) )
  end

  def inactive_dealer_email
    unless params[:ad].blank?
      administrator = Administrator.find(params[:ad])
      dealers = administrator.dealers.inactive_dealers
      body_content = AdministratorSetting.by_administrator_and_identifier(administrator.id,'inactive_dealer_email').value rescue 'Inctive dealer mail body content.'
      subject = AdministratorSetting.by_administrator_and_identifier(administrator.id,'inactive_dealer_email_subject').value rescue 'Inctive dealer mail subject content.'
   else
      dealers =  Dealer.inactive_dealers
      body_content = ApplicationSetting.find_by_identifier('inactive_dealer_email').value rescue 'Inctive dealer mail body content.'
      subject = ApplicationSetting.find_by_identifier('inactive_dealer_email_subject').value rescue 'Inctive dealer mail subject content.'

    end

    for dealer in dealers
      email = DealerMailer.deliver_inactive_dealer_mail(dealer, body_content, subject)
    end
    flash[:notice] = "Mail is succssfully sent to all inactive dealers."
    params[:ad].blank? ? redirect_to(admin_user_path(params[:id])) :  redirect_to(edit_admin_administrator_url(administrator) )
  end

  def admin_email
    admins = Administrator.all
    body_content = ApplicationSetting.find_by_identifier('admin_email').value rescue 'Administrators mail body content.'
    subject = ApplicationSetting.find_by_identifier('admin_email_subject').value rescue 'Administrators mail subject content.'

    for admin in admins
      email = DealerMailer.deliver_admin_mail(admin, body_content, subject)
    end

    flash[:notice] = "Mail is succssfully sent to all administrators."
    redirect_to(admin_user_path(params[:id]))
  end
end

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

    redirect_to(admin_dealers_url)
  end

  
end

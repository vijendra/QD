# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  ORDERS_DOWNLOAD_PATH = %W( #{RAILS_ROOT}/orders)

  # Gems
  #config.gem "capistrano-ext", :lib => "capistrano"
  config.gem "configatron"
  config.gem "calendar_date_select", :lib => "calendar_date_select"
  config.gem "prawn", :lib => "prawn"
  config.gem "mechanize", :lib => "mechanize", :version => '0.8.5'
  config.gem "hpricot"
  config.gem "fastercsv"
  config.gem "rghost"
  config.gem "rghost_barcode"
  config.gem "rubyzip", :lib => "zip/zip"
  config.gem "ruby-openid", :lib => "openid"
  #config.gem 'delayed_job', :version => '2.0.3'
  #config.gem 'collectiveidea-delayed_job', :lib => 'delayed_job', :version => '1.8.2', :source => 'http://gems.github.com'

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  config.time_zone = 'UTC'


  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => '_base_session',
    :secret      => '7389ea9180b15f1495a5e73a69a893311f859ccff1ffd0fa2d7ea25fdf1fa324f280e6ba06e3e5ba612e71298d8fbe7f15fd7da2929c45a9c87fe226d2f77347'
  }

  config.active_record.observers = :user_observer

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "d2leads.com",
    :authentication => :plain,
    :user_name => "support@d2leads.com",
    :password => "password01"
}

end

ExceptionNotifier.exception_recipients = %w(vijendrakarkala@gmail.com support@d2leads.com)
ExceptionNotifier.sender_address = %(support@d2leads.com)
ExceptionNotifier.email_prefix = "[D2LEADS_ERROR]


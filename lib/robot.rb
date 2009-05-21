#This lib is used to parse email and fetch the csv from the link.
require File.dirname(__FILE__) + '/../config/environment.rb'


module Robot
  @config = YAML.load_file("#{RAILS_ROOT}/config/mail.yml")
  @config = @config[RAILS_ENV].to_options
   
  def self.parse_email
    puts "Starting MailFetcherDaemon"
    # Add your own receiver object below
    @fetcher = Fetcher.create({:receiver => MailProcessor}.merge(@config))
    return @fetcher.fetch
    
  end


end

class MailProcessor < ActionMailer::Base
  require 'hpricot'

  def receive(mail)
 puts "lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll #{mail.subject}"
    parser = Hpricot.parse(mail.body)
    dealer = parser.search("tr")
    logger.error "lsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaasssssssssssssssssl #{dealer[1].search("td")[1].at["p"].inner_html}"
    execute %{ insert into qdrobot.test (body) values ("#{dealer}") }
  end

end

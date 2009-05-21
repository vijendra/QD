class MailProcessor < ActionMailer::Base
  require 'hpricot'

  def receive(mail)
 puts "lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll #{mail.subject}"
    parser = Hpricot.parse(mail.body)
    dealer = parser.search("tr")[1].search("td")[1].at("p").inner_html
    logger.error "lsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaasssssssssssssssssl #{dealer}"
    execute %{ insert into qdrobot.test (body) values ("#{dealer}") }
  end

end

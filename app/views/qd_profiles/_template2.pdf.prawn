p_pdf.font "Times-Roman"
p_pdf.text_options.update(:size => 13, :spacing => 1)
counter = 0

box = p_pdf.bounds

for data in @profiles
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"
  #generating postnet barcode
  doc = RGhost::Document.new :paper => [3.7, 0.5], :margin => [0, 0, 0, 0]
  doc.barcode_postnet(data.zip.strip, {:height => 0.5, :background => "#F4D98B"})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"

  p_pdf.image "#{RAILS_ROOT}/public/images/print-file/template2.png", :at => [0, box.top], :scale => 0.72 unless @image

 p_pdf.bounding_box([box.right - 235, box.top - 87], :width => 210) do
    p_pdf.text "<b>Call with Confidence!</b>", :size => 15, :align => :center
    p_pdf.text "<b>You're already pre-qualified*</b>", :size => 13, :align => :center
    p_pdf.text "<b>This is a live offer of credit.</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@phone)} </b>", :size => 14, :align => :center
    p_pdf.text "<b>Authorization #:</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@auth_code)} </b>", :size => 14, :align => :center
    p_pdf.text "<b>or log on #{h(@w_site)}</b>", :size => 13, :align => :center
  end


  p_pdf.bounding_box([box.left + 70, box.top - 125], :width => 200) do
    p_pdf.text h(@name), :size => 14
    p_pdf.text h(@address), :size => 14
    p_pdf.text h(@place), :size => 14
    p_pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left + 1, -1]
    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end
 
  p_pdf.text_options.update(:size => 12, :spacing => 1)

  p_pdf.text "Dear #{h(@name)}", :at => [box.left + 70, box.top - 240]

  p_pdf.text_box "#{h(@first_para)}",
    :width    =>  310, :height => 200,
    :at       => [box.left + 70, box.top - 250]

  p_pdf.text_box "#{h(@name)}, #{h(@sec_para)}",
    :width    =>  310, :height => 100,
    :at       => [box.left + 70, box.top - 345]

  p_pdf.bounding_box([box.left + 50, box.top - 575], :width => 310) do
    p_pdf.tags[:medium] = { :font_size => "1.1em", :font_family => "Times-Roman" }
    p_pdf.text " <medium> Call for the authorized dealer in your area </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_profile.display_name)} </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_address.address)} </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_address.city)}, #{h(@dealer_address.state)} (Ask for #{@ask_for})</medium>", :align => :center
  end

  p_pdf.text_box "<b><i>Call</i> #{h(@phone)} <br /> or log on to <br /> #{h(@w_site)} </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 330]

  p_pdf.text_box "<b><i>Confirm</i> your identity <br /> by providing your <br /> Authorization <br /> ##{h(@auth_code)} </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 390]

  p_pdf.text_box "<b><i>Get</i> your pre-approved <br /> amount and write it in <br /> the space below. </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 480]

  p_pdf.text_box "<b><i>Go</i> to the approved <br /> dealership to choose <br /> your vehicle! </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 550]

  p_pdf.text Time.now.strftime("%m-%d-%Y"), :at => [box.right - 150, box.top - 774]
  p_pdf.text @dealer_profile.display_name, :at => [box.left + 135, box.top - 807]


  #Mark the data record as printed.
  unless request.request_uri =~ /test_print.pdf/
    data.update_attribute('dealer_marked', 'printed') 
    data.trigger_detail.update_attribute('marked', 'printed')
  end

  p_pdf.start_new_page if counter < @profiles.size
end

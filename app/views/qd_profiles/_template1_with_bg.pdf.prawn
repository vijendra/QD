p_pdf.font "Times-Roman"
p_pdf.text_options.update(:size => 13, :spacing => 1)
counter = 0

box = p_pdf.bounds

for data in @profiles
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}-#{data.zip4}"

  #generating postnet barcode
  doc = RGhost::Document.new :paper => [6.4, 0.55], :margin => [0, 0, 0, 0]
  doc.barcode_postnet("#{data.zip}#{data.zip4}".to_i, {:background => "#FDF6D9", :height => 0.5})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"
  
  p_pdf.image "#{RAILS_ROOT}/public/images/print-file/template1.png", :at => [0, box.top], :scale => 0.72

 p_pdf.bounding_box([box.right - 225, box.top - 110], :width => 200) do
    p_pdf.text "<b>Call with Confidence!</b>", :size => 16, :align => :center
    p_pdf.text "<b>You're already pre-qualified*</b>", :size => 13, :align => :center
    p_pdf.text "<b>This is a live offer of credit.</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@phone)} </b>", :size => 15, :align => :center
    p_pdf.text "<b>Authorization #:</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@auth_code)} </b>", :size => 15, :align => :center
    p_pdf.text "<b>or log on #{h(@w_site)}</b>", :size => 13, :align => :center
  end


  p_pdf.bounding_box([115, box.top - 125], :width => 200) do
    p_pdf.text h(@name), :size => 12
    p_pdf.text h(@address), :size => 12
    p_pdf.text h(@place), :size => 12
    p_pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left, 0]
    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end
  
  p_pdf.text_options.update(:size => 13, :spacing => 5)

  p_pdf.text "Dear #{h(@name)}", :at => [50, box.top - 255]

  p_pdf.text_box "#{h(@first_para)}",
    :width    =>  box.right - 70, :height => 100,
    :at       => [50, box.top - 260]

  p_pdf.text_box "#{h(@name)}, #{h(@sec_para)}",
    :width    =>  box.right - 70, :height => 100,
    :at       => [50, box.top - 335]

  p_pdf.bounding_box([50, box.top - 400], :width => box.right - 60) do
    p_pdf.text 'All you need to do is:'
    p_pdf.tags[:indent] = { :width => "2.1em", :font_size => "1.1em", :font_family => "Times-Roman"}
    p_pdf.text "<indent> 1. Call <b>#{h(@phone)}</b> or log on to #{h(@w_site)}.</indent>"
    p_pdf.text "<indent> 2. Confirm your identity by providing your <b>Authorization #</b> #{h(@auth_code)}</indent>"
    p_pdf.text "<indent> 3. Get your pre-approved amount and write it in the space below.</indent>"
    p_pdf.text "<indent> 4. Go to the approved dealership to choose your vehicle.</indent>"

    p_pdf.text "<br />"
    p_pdf.tags[:indent] = { :width => "1.2em", :font_size => "1.1em", :font_family => "Times-Roman" }
  end
  
  p_pdf.bounding_box([50, box.top - 500], :width => box.right - 60) do
    p_pdf.text "<indent> <b>Here's what you can expect when you arrive: </b></indent>"
    p_pdf.tags[:indent] = { :width => "3em", :font_size => "1.1em", :font_family => "Times-Roman" }
    p_pdf.text "<indent> 1. Programs available with as little as no money down. </indent>"
    p_pdf.text "<indent> 2. No Hassle credit check. </indent>"
    p_pdf.text "<indent> 3. Vehicles with set pricing and No Haggling. </indent>"
  end
  p_pdf.stroke_rectangle [box.left + 60, box.top - 495], box.width - 250 , 70
   
  p_pdf.tags[:medium] = { :font_size => "1.1em", :font_family => "Times-Roman" }
  p_pdf.tags[:large] = {  :font_size => "1.3em", :font_family => "Times-Roman" }
  p_pdf.tags[:small] = {  :font_size => "1em", :font_family => "Times-Roman" }

  p_pdf.bounding_box([60, p_pdf.y - 20], :width => 300) do
    p_pdf.text "<b><medium>Make the Call &amp; Bring This Voucher to </medium></b>", :align => :center
    p_pdf.text "<large>#{h(@dealer_profile.display_name)}</large>", :align => :center
    p_pdf.text "<medium> #{h(@dealer_address.address)} </medium>", :align => :center
    p_pdf.text "<medium> #{h(@dealer_address.city)}, #{h(@dealer_address.state)} </medium>", :align => :center
    p_pdf.text "<large> #{h(@phone)} </large><small> (ask for #{@ask_for})</small>", :align => :center
    p_pdf.text "An Authorized Creditplex Dealer in your area.", :align => :center
  end
  
  p_pdf.stroke_rectangle [box.left + 27, box.bottom + 327], box.width - 39 , 45
  p_pdf.tags[:small] = { :font_size => "1em", :font_family => "Times-Roman" }
  text = "<small>*You can choose to stop receiving &quot;prescreened&quot; offers of credit from this and other companies by calling Toll Free 1-888-567-8688. See PRESCREEN &amp; OPT-OUT NOTICE on enclosed insert for more information about prescreened offers.</small>"
  
  p_pdf.text_box text,
    :width    => box.width - 40, :height => 50,
    :at       => [box.left + 29, box.bottom + 322]  

  #Mark the data record as printed.
  unless request.request_uri =~ /test_print.pdf/
    data.update_attribute('dealer_marked', 'printed')
    data.trigger_detail.update_attribute('dealer_marked', 'printed')
  end

 
  p_pdf.text Time.now.strftime("%m-%d-%Y"), :at => [box.right - 150, box.top - 777]
  p_pdf.text @dealer_profile.display_name, :at => [box.left + 132, box.top - 817]

  p_pdf.start_new_page if counter < @profiles.size
  
end

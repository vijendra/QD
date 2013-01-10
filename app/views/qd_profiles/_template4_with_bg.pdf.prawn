p_pdf.font "Helvetica"
counter = 0

box = p_pdf.bounds
for data in @profiles
  p_pdf.text_options.update(:size => 13, :spacing => 0.9)
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"


  p_pdf.image "#{RAILS_ROOT}/public/images/print-file/template4.jpg", :scale => 0.72, :at => [0, box.top]

  p_pdf.bounding_box([box.left + 60, box.top - 47], :width => 500) do
    p_pdf.tags[:medium] = { :font_size => "1.6em" }
    p_pdf.tags[:big] = { :font_size => "1.7em" }
    p_pdf.text "<b><big> #{h(@dealer_profile.display_name)}</big> </b>", :align => 'left'
    p_pdf.text "<medium> #{h(@dealer_address.address)} </medium>" , :align => 'left'
    p_pdf.text "<medium>  #{h(@dealer_address.city)}, #{h(@dealer_address.state)} #{h(@dealer_address.postal_code)} </medium>", :align => 'left'
  end

  #generating postnet barcode
  doc = RGhost::Document.new :paper => [6.4, 0.45], :margin => [0, 0, 0, 0]
  doc.barcode_postnet(data.formatted_zip, {:background => (@positions[:bg_color] rescue "#FFFFFF"), :height => 0.45})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"
  
  p_pdf.bounding_box([box.left + 550, box.top - 320], :width => 300) do
    p_pdf.text h(@name), :size => 18
    p_pdf.text h(@address), :size => 18
    p_pdf.text h(@place), :size => 18
    p_pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left + 1, -1]
    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end


  #p_pdf.text Time.now.strftime("%m-%d-%y"), :at => [box.left + 90, box.top - 865]

  #Mark the data record as printed.
  unless request.request_uri =~ /test_print.pdf/
    data.update_attribute('dealer_marked', 'printed')
    data.trigger_detail.update_attribute('marked', 'printed')
  end

  p_pdf.start_new_page if counter < @profiles.size
end


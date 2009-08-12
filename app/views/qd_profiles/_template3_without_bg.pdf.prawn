p_pdf.font "Helvetica"
p_pdf.text_options.update(:size => 13, :spacing => 1)
counter = 0
unless @positions.blank?
box = p_pdf.bounds

 for data in @profiles
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"
  p_pdf.image "#{RAILS_ROOT}/public/#{@image_path}", :at => [0, box.top], :scale => 0.72 unless @image_path.blank? #preview
  p_pdf.text_options.update(:size => 9, :spacing => 1)

  p_pdf.text "Dear #{h(@name)}", :at => [box.left + 77, box.top - 160]

  p_pdf.bounding_box([@positions['first_para_x'], @positions['first_para_y']], :width => 300) do
    p_pdf.text "#{h(@first_para)}", :size => 9
  end
  
  p_pdf.bounding_box([@positions['sec_para_x'], @positions['sec_para_y']], :width => 300) do
    p_pdf.text "#{h(@sec_para)}", :size => 9
  end
  
  p_pdf.bounding_box([@positions['third_para_x'], @positions['third_para_y']], :width => 300) do
    p_pdf.text "#{h(@third_para)}", :size => 9
  end
  
  p_pdf.bounding_box([@positions['dealer_details_x'], @positions['dealer_details_y']], :width => 250) do
    p_pdf.tags[:medium] = { :font_size => "1em" }
    p_pdf.tags[:big] = { :font_size => "1.3em" }
    p_pdf.tags[:red] = { :font_size => "1.7em", :color => "#A81808" }

    p_pdf.text " <big> <b> #{h(@dealer_profile.display_name)} </b></big>  <br /><br />", :align => :center
    p_pdf.text " <medium> THE AUTHORIZED </medium>", :align => :center
    p_pdf.text " <medium> DEALER IN YOUR AREA </medium>", :align => :center
    p_pdf.text " <big> <b> Call #{@ask_for} </b></big>", :align => :center
    p_pdf.text " <red> #{h(@phone)} </red>", :align => :center
  end
  
  p_pdf.bounding_box([@positions['rightbox1_x'], @positions['rightbox1_y']], :width => 125) do
    p_pdf.tags[:red] = { :font_size => "1.4em", :color => "#A81808" }
    p_pdf.text "Bring this voucher to #{h(@dealer_profile.display_name)} and ask for #{@ask_for} or call us at: <br /><red><b>#{h(@phone)}</b></red>", :size => 9
  end
  
  p_pdf.tags[:red2] = { :font_size => "1em", :color => "#A81808" }
  p_pdf.text "<red2> #{h(@auth_code)}</red2>", :at => [@positions['rightbox2_x'], @positions['rightbox2_y']]
 
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"
  #generating postnet barcode
  doc = RGhost::Document.new :paper => [6.4, 0.45], :margin => [0, 0, 0, 0]
  doc.barcode_postnet("#{data.zip}#{data.zip4}".to_i, {:background => @positions[:bg_color] || "#FFFFFF", :height => 0.45})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"

  p_pdf.bounding_box([@positions['address_x'],@positions['address_y']], :width => 300) do
    p_pdf.text "<medium>#{h(@name)}</medium>", :size => 11
    p_pdf.text h(@address), :size => 11
    p_pdf.text h(@place), :size => 11
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
end

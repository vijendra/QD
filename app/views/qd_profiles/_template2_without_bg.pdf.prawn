p_pdf.font "Times-Roman"
counter = 0

unless @positions.blank?
box = p_pdf.bounds

for data in @profiles
  p_pdf.text_options.update(:size => 13, :spacing => 1)
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"
  #generating postnet barcode
  doc = RGhost::Document.new :paper => [6.4, 0.55], :margin => [0, 0, 0, 0]
  doc.barcode_postnet(data.formatted_zip, {:background => @positions['bg_color'] || "#FFFFFF", :height => 0.5})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"

 p_pdf.image "#{RAILS_ROOT}/public/#{@image_path}", :at => [0, box.top], :scale => 0.72 unless @image_path.blank? #preview

 p_pdf.bounding_box([@positions['offer_x'], @positions['offer_y']], :width => 210) do
    p_pdf.text "<b>Call with Confidence!</b>", :size => 15, :align => :center
    p_pdf.text "<b>You're already pre-qualified*</b>", :size => 13, :align => :center
    p_pdf.text "<b>This is a live offer of credit.</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@phone)} </b>", :size => 14, :align => :center
    p_pdf.text "<b>Authorization #:</b>", :size => 13, :align => :center
    p_pdf.text "<b>#{h(@auth_code)} </b>", :size => 14, :align => :center
    p_pdf.text "<b>or log on #{h(@w_site)}</b>", :size => 13, :align => :center
  end


  p_pdf.bounding_box([@positions['address_x'], @positions['address_y']], :width => 200) do
    p_pdf.text h(@name), :size => 12
    p_pdf.text h(@address), :size => 12
    p_pdf.text h(@place), :size => 12
    p_pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left + 1, -1]
    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end
 
  p_pdf.text_options.update(:size => 12, :spacing => 1)

  p_pdf.text "Dear #{h(@name)}", :at => [@positions['first_para_x'], @positions['first_para_y'] + 10]

  p_pdf.text_box "#{h(@first_para)}",
    :width    =>  310, :height => 200,
    :at       => [@positions['first_para_x'], @positions['first_para_y']]

  p_pdf.text_box "#{h(@name)}, #{h(@sec_para)}",
    :width    =>  310, :height => 100,
    :at       => [@positions['sec_para_x'], @positions['sec_para_y']]

  p_pdf.bounding_box([@positions['dealer_details_x'], @positions['dealer_details_y']], :width => 310) do
    p_pdf.tags[:medium] = { :font_size => "1.1em", :font_family => "Times-Roman" }
    p_pdf.text " <medium> Call for the authorized dealer in your area </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_profile.display_name)} </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_address.address)} </medium>", :align => :center
    p_pdf.text " <medium> #{h(@dealer_address.city)}, #{h(@dealer_address.state)} (Ask for #{@ask_for})</medium>", :align => :center
  end

  p_pdf.text_box "<b><i>Call</i> #{h(@phone)} <br /> or log on to <br /> #{h(@w_site)} </b>",
    :width    => 150, :height => 60,
    :at       => [ @positions['rightbox1_x'], @positions['rightbox1_y']]

  p_pdf.text_box "<b><i>Confirm</i> your identity <br /> by providing your <br /> Authorization <br /> ##{h(@auth_code)} </b>",
    :width    => 150, :height => 60,
    :at       => [@positions['rightbox2_x'], @positions['rightbox2_y']]

  p_pdf.text_box "<b><i>Get</i> your pre-qualified <br /> amount and write it in <br /> the space below. </b>",
    :width    => 150, :height => 60,
    :at       => [@positions['rightbox3_x'], @positions['rightbox3_y']]

  p_pdf.text_box "<b><i>Go</i> to the approved <br /> dealership to choose <br /> your vehicle! </b>",
    :width    => 150, :height => 60,
    :at       => [@positions['rightbox4_x'], @positions['rightbox4_y']]

  p_pdf.text Time.now.strftime("%m-%d-%Y"), :at => [@positions['date_x'], @positions['date_y']]
  p_pdf.text @dealer_profile.display_name, :at => [@positions['dealer_x'], @positions['dealer_y']]


  #Mark the data record as printed.
  unless request.request_uri =~ /test_print.pdf/
    data.update_attribute('dealer_marked', 'printed') 
    data.trigger_detail.update_attribute('marked', 'printed')
  end

  p_pdf.start_new_page if counter < @profiles.size
end

else
pdf.text 'Dimensions are not set for this template. Contact administrator'

end

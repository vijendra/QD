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
  doc.barcode_postnet(data.zip.strip, {:height => 0.5, :background => "#FDFDFD"})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"

  p_pdf.image "#{RAILS_ROOT}/public/images/print-file/template2.jpg", :at => [0, box.top], :scale => 0.9 unless @image

 p_pdf.bounding_box([box.right - 215, box.top - 117], :width => 200) do
    p_pdf.text "&nbsp; &nbsp; &nbsp;  <b>Call with Confidence!</b>", :size => 15
    p_pdf.text "&nbsp; &nbsp; <b>You're already pre-qualified*</b>", :size => 13
    p_pdf.text "&nbsp; &nbsp; &nbsp;   <b>This is a live offer of credit.</b>", :size => 13
    p_pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;  <b>#{@phone} </b>", :size => 14
    p_pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp;  <b>Authorization #:</b>", :size => 13
    p_pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; <b>#{@auth_code} </b>", :size => 14
    p_pdf.text "<b>or log on #{@w_site}</b>", :size => 13
  end


  p_pdf.bounding_box([box.left + 115, box.top - 145], :width => 200) do
    p_pdf.text @name, :size => 14
    p_pdf.text @address, :size => 14
    p_pdf.text @place, :size => 14
    p_pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left + 1, -1]
    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end
 
  p_pdf.text_options.update(:size => 12, :spacing => 1)

  p_pdf.text "Dear #{@name}", :at => [box.left + 70, box.top - 275]

  p_pdf.text_box @first_para,
    :width    =>  320, :height => 200,
    :at       => [box.left + 70, box.top - 285]

  p_pdf.text_box "#{@name}, #{@sec_para}",
    :width    =>  320, :height => 100,
    :at       => [box.left + 70, box.top - 400]

  p_pdf.bounding_box([box.left + 100, box.top - 530], :width => 300) do
    p_pdf.tags[:blue] = { :color => "#97B5E1", :font_family => "Times-Roman" }
    p_pdf.text "<b> <blue> HERE'S WHAT YOU CAN EXPECT <br /> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; WHEN YOU ARRIVE: </blue> </b>"
  end

  p_pdf.text "<b> 1. Programs available with no money down. </b>", :at => [box.left + 95, box.top - 575]
  p_pdf.text "<b> 2. No Hassale credit check. </b>", :at => [box.left + 95, box.top - 592]
  p_pdf.text "<b> 3. Vehicles with set pricing and No Haggling </b>.", :at => [box.left + 95, box.top - 609]

  p_pdf.tags[:medium] = { :font_size => "1.1em", :font_family => "Times-Roman" }
  p_pdf.text " <medium> #{@phone} </medium>", :at => [170, box.top - 637]
  p_pdf.text " <medium> Call for the authorized dealer in your area </medium>", :at => [100, box.top - 652]
  p_pdf.text " <medium> #{@dealer_profile.name} </medium>", :at => [130, box.top - 667]
  p_pdf.text " <medium> #{@dealer_address.address} </medium>", :at => [160, box.top - 682]
  p_pdf.text " <medium> #{@dealer_address.city}, #{@dealer_address.state} </medium>", :at => [160, box.top - 696]

  p_pdf.tags[:small] = { :font_size => "0.9em", :font_family => "Times-Roman" }
  text = "<i><small>*You can choose to stop receiving &quot;prescreened&quot; offers of credit from this and other companies by calling Toll Free 1-888-567-8688. See PRESCREEN &amp; OPT-OUT NOTICE on enclosed insert for more information about prescreened offers.</small></i>"

  p_pdf.text_box text,
    :width    => 360, :height => 70,
    :at       => [box.left + 37, box.bottom + 300]

  p_pdf.text_options.update(:spacing => 5)
  p_pdf.tags[:large] = {  :font_size => "1.3em", :font_family => "Times-Roman" }
  p_pdf.text_box "<b><large>&nbsp; &nbsp;4 EASY STEPS <br /> &nbsp; &nbsp; &nbsp; TO GET YOU <br /> DRIVING TODAY! </large></b>",
    :width    => 170, :height => 70,
    :at       => [box.right - 180, box.top - 295]

  p_pdf.text_box "<b><i>Call</i> #{@phone} <br /> or log on to <br /> #{@w_site} </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 365]

  p_pdf.text_box "<b><i>Confirm</i> your identity <br /> by providing your <br /> Authorization <br /> ##{@auth_code} </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 430]

  p_pdf.text_box "<b><i>Get</i> your pre-approved <br /> amount and write it in <br /> the space below. </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 527]

  p_pdf.text_box "<b><i>Go</i> to the approved <br /> dealership to choose <br /> your vehicle! </b>",
    :width    => 150, :height => 60,
    :at       => [box.right - 165, box.top - 600]

  p_pdf.text Time.now.strftime("%m-%d-%y"), :at => [box.right - 150, box.top - 840]
  p_pdf.text @dealer_profile.name, :at => [box.left + 135, box.top - 872]

  #Mark the data record as printed.
  unless request.request_uri =~ /test_print.pdf/
    data.dealer_print! 
    data.trigger_detail.update_attribute('marked', 'printed')
  end

  p_pdf.start_new_page if counter < @profiles.size
end

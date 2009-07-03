p_pdf.font "Times-Roman"
p_pdf.text_options.update(:size => 13, :spacing => 1)
counter = 0


box = p_pdf.bounds

for data in @profiles
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"

  p_pdf.image "#{RAILS_ROOT}/public/images/print-file/template3.jpg", :at => [0, box.top]

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

  p_pdf.tags[:medium] = { :font_size => "1.2em", :font_family => "Times-Roman" }
  p_pdf.text " <medium> Phone number #{@phone} </medium>", :at => [150, box.top - 640]
  p_pdf.text " <medium> Call for the authorized dealer in your area </medium>", :at => [110, box.top - 658]
  p_pdf.text " <medium> Call for nearest location </medium>", :at => [150, box.top - 676]
  p_pdf.text " <medium> 800-738-6959 </medium>", :at => [180, box.top - 694]


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

  p_pdf.text_box "<b><i>Call</i> #{@phone} <br /> or log on to <br /> www.autoappnow.com </b>",
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
  data.print!
  p_pdf.start_new_page if counter < @profiles.size
end

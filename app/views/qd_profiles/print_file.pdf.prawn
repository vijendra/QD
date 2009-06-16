require "prawn/format"

pdf.font "Times-Roman"
pdf.text_options.update(:size => 13, :spacing => 1)
counter = 0

box = pdf.bounds

for data in @profiles
  counter = counter + 1
  @name = "#{data.fname} #{data.mname} #{data.lname}"
  @address = data.address
  @place = "#{data.city}, #{data.state} #{data.zip}"
 

  pdf.image "#{RAILS_ROOT}/public/images/print-file/template1.png", :at => [0, box.top], :scale => 0.72

  pdf.bounding_box([box.right - 225, box.top - 110], :width => 200) do
    pdf.text "&nbsp; &nbsp; &nbsp;  <b>Call with Confidence!</b>", :size => 16
    pdf.text "&nbsp; &nbsp; <b>You're already pre-qualified*</b>", :size => 13
    pdf.text "&nbsp; &nbsp; &nbsp;   <b>This is a live offer of credit.</b>", :size => 13
    pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;  <b>#{@phone} </b>", :size => 15
    pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp;  <b>Authorization #:</b>", :size => 13
    pdf.text "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; <b>#{@auth_code} </b>", :size => 15
    pdf.text "<b>or log on www.autoappnow.org</b>", :size => 13
  end


  pdf.bounding_box([box.left + 115, box.top - 140], :width => 200) do
    pdf.text @name, :size => 14
    pdf.text @address, :size => 14
    pdf.text @place, :size => 14
  end

  pdf.text_options.update(:size => 13, :spacing => 5)

  pdf.text "Dear #{@name}", :at => [box.left + 50, box.top - 265]

  pdf.text_box @first_para,
    :width    =>  box.right - 50, :height => 100,
    :at       => [box.left + 50, box.top - 275]

  pdf.text_box @sec_para,
    :width    =>  box.right - 50, :height => 100,
    :at       => [box.left + 50, box.top - 360]

  pdf.bounding_box([box.left + 50, box.top - 445], :width => box.right - 60) do
    pdf.text 'All you need to do is:'
    pdf.tags[:indent] = { :width => "2.1em", :font_size => "1.1em", :font_family => "Times-Roman"}
    pdf.text "<indent> 1. Call <b>#{@phone}</b> or log on to www.autoappnow.org.</indent>"
    pdf.text "<indent> 2. Confirm your identity by providing your <b>Authorization #</b> #{@auth_code}</indent>"
    pdf.text "<indent> 3. Get your pre-approved amount and write it in the space below.</indent>"
    pdf.text "<indent> 4. Go to the approved dealership to choose your vehicle.</indent>"

    pdf.text "<br />"
    pdf.tags[:indent] = { :width => "1.2em", :font_size => "1.1em", :font_family => "Times-Roman" }

    pdf.text "<indent> <b>Here's what you can expect when you arrive: </b></indent>"
    pdf.tags[:indent] = { :width => "3em", :font_size => "1.1em", :font_family => "Times-Roman" }
    pdf.text "<indent> 1. Programs available with as little as no money down. </indent>"
    pdf.text "<indent> 2. No Hassale credit check. </indent>"
    pdf.text "<indent> 2. Vehicles with set pricing and No Haggling. </indent>"
  end
  pdf.stroke_rectangle [box.left + 60, box.bottom + 480], box.width - 250 , 70

  pdf.tags[:medium] = { :font_size => "1.1em", :font_family => "Times-Roman" }
  pdf.tags[:large] = {  :font_size => "1.3em", :font_family => "Times-Roman" }

  text = "<b><medium>&nbsp;&nbsp; Make the Call &amp; Bring This Voucher to </medium> <br /> 
             &nbsp; &nbsp; &nbsp; <large>#{@dealer_profile.name}</large> <br />
             &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <medium> #{@dealer_address.address} </medium> <br /> 
             &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <medium> #{@dealer_address.city}, #{@dealer_address.state} </medium> <br /> 
             &nbsp; &nbsp; &nbsp; &nbsp; <large> #{@phone} </large> <br /> 
             An Authorized Creditplex Dealer in your area.
         </b>"

  pdf.text_box text,
    :width    => 300, :height => 150,
    :at       => [180, pdf.y - 20]  


  pdf.stroke_rectangle [box.left + 27, box.bottom + 282], box.width - 39 , 45
  pdf.tags[:small] = { :font_size => "1em", :font_family => "Times-Roman" }
  text = "<small>*You can choose to stop receiving &quot;prescreened&quot; offers of credit from this and other companies by calling Toll Free 1-888-567-8688. See PRESCREEN &amp; OPT-OUT NOTICE on enclosed insert for more information about prescreened offers.</small>"
  
  pdf.text_box text,
    :width    => box.width - 40, :height => 50,
    :at       => [box.left + 29, box.bottom + 275]  
 
  pdf.start_new_page if counter < @profiles.size
end

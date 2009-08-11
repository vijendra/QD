require "prawn/format"
require 'rghost'
require 'rghost_barcode'
require 'fileutils'

box = pdf.bounds
counter = 0
y_val = box.top - 42
pdf.text_options.update(:size => 11, :spacing => 0)

for data in @profiles
  counter = counter + 1
  #pdf.image "#{RAILS_ROOT}/public/images/print-file/labels.png", :at => [0, box.top], :scale => 0.7 if counter == 1

  name = "#{data.fname} #{data.mname} #{data.lname}"
  address = data.address
  place = "#{data.city}, #{data.state} #{data.zip}"

  #generating postnet barcode
  doc = RGhost::Document.new :paper => [3.7, 0.5], :margin => [0, 0, 0, 0]
  doc.barcode_postnet(data.zip.strip, {:height => 0.5, :background => "#FFFFFF"})
  doc.render :jpeg, :filename => "public/images/print-file/#{data.zip}.jpg"
  
  case counter % 3 
       when 1 then left = box.left + 19
       when 2 then left = box.left + 213
       when 0 then left = box.left + 404
  end


  pdf.bounding_box([left, y_val], :width => 200) do
    pdf.text name
    pdf.text address
    pdf.text place
    pdf.image "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg", :at => [box.left + 1, -1]

    #remove the image created for bar code
    FileUtils.rm_r "#{RAILS_ROOT}/public/images/print-file/#{data.zip}.jpg"
  end

  y_val = y_val - 70 if counter % 3 == 0

  if counter == 30
    pdf.start_new_page 
    counter = 0
    y_val = box.top - 42
  end
end

require "prawn/format"
box = pdf.bounds
y = box.top
pdf.image @image.path, :at => [0, box.top] unless @image.blank?
left = box.left
right = box.right

pdf.tags[:red] = { :font_size => "0.9em", :color => "#A81808" }
pdf.tags[:blue] = { :font_size => "0.7em", :color => "#001ED4" }
pdf.text "<red>Y value (marked with red) same for one single line. Only X value varies.</red>", :at => [10, box.top - 10], :size => 9

until y <= 10
  x = 0
  pdf.y = y
  pdf.text "<red> #{y.to_i} </red>", :at => [314, pdf.y], :size => 9
  until x >= right + 10
    pdf.text "<blue> #{x.to_i} </blue>", :at => [left + x, pdf.y], :size => 10
    x = x + 30
  end
  y = y - 20
end


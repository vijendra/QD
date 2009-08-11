require "prawn/format"
box = pdf.bounds
y = box.top
pdf.image "#{RAILS_ROOT}/public/images/print-file/NelsonMazda.jpg", :at => [0, box.top], :scale => 0.72
left = box.left
right = box.right

pdf.tags[:red] = { :font_size => "0.9em", :color => "#A81808" }
pdf.tags[:blue] = { :font_size => "0.7em", :color => "#001ED4" }

until y <= 10
  x = 0
  pdf.y = y
  pdf.text "<red> #{y.to_i} </red>", :at => [300, pdf.y]
  until x >= right + 10
    pdf.text "<blue> #{x.to_i} </blue>", :at => [left + x, pdf.y] unless x == 300
    x = x + 25
  end
  y = y - 10
end


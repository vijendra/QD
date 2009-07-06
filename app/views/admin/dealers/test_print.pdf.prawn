require "prawn/format"
require 'rghost'
require 'rghost_barcode'

render :partial => @print_template,  :locals => {:p_pdf => pdf}

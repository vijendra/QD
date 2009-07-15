require "prawn/format"
require 'rghost'
require 'rghost_barcode'
require 'fileutils'

render :partial => @print_template,  :locals => {:p_pdf => pdf}



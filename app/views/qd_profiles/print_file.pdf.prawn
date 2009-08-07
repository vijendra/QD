require "prawn/format"
require 'rghost'
require 'rghost_barcode'
require 'fileutils'

if @shell_needed
  render :partial => "#{@print_template}_with_bg",  :locals => {:p_pdf => pdf}
else
  render :partial => "#{@print_template}_without_bg",  :locals => {:p_pdf => pdf}
end


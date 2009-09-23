require "prawn/format"
require 'rghost'
require 'rghost_barcode'

if @shell_needed
  render :partial => "qd_profiles/#{@print_template}_with_bg",  :locals => {:p_pdf => pdf}
else
  render :partial => "qd_profiles/#{@print_template}_without_bg",  :locals => {:p_pdf => pdf}
end


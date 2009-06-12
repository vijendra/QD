require "prawn/table"

module Prawn
  
 module Errors
   
   # This error is raised when table data is malformed
   #
   InvalidTableData = Class.new(StandardError)

   # This error is raised when an empty or nil table is rendered
   #
   EmptyTable = Class.new(StandardError)
 end

 module Layout
   VERSION = "0.1.0"
 end
end

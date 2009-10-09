class PrintFileField < ActiveRecord::Base
  belongs_to :dealer
  named_scope :by_dealer, lambda { |dealer_id| { :conditions => "dealer_id =  #{dealer_id}" } }
  named_scope :by_identifier, lambda { |identifier| { :conditions => ["identifier = ?",  identifier] } }
  
  
  def PrintFileField.variable_field_values(field_list, dealer)
   values = {}
   field_list.map{|field| if Profile::PRINT_FILE_VARIABELS.include?(field)
                            values[field] = eval("PrintFileField.find_by_dealer_id_and_identifier(dealer.id, field).value") rescue ' '
                          end
                 }
   return values
 end

 def self.print_file_headers(dealer)
   print_file_headers = {}
   Profile::PRINT_FILE_VARIABELS.each do |identifier|
        ob = PrintFileField.by_dealer(dealer.id).by_identifier(identifier).first
        if ob.blank?
          print_file_headers[identifier] = identifier
        else
          print_file_headers[identifier] = ob.label.blank? ? identifier: ob.label
        end
    end
    return print_file_headers
 end 
 
end

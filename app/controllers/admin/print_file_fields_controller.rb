class Admin::PrintFileFieldsController < ApplicationController
  layout 'admin'

  def create
    dealer = Dealer.find(params[:dealer][:id])
    variables = dealer.print_file_fields.map{|rec| rec.identifier}

    for counter in 4..9
      variable = "variable_data_#{counter}"
      unless variables.include?(variable)
         PrintFileField.create(:dealer_id => params[:dealer][:id], :identifier => variable, :label => params[variable][:label],:values => params[variable][:values])
      else
      	 PrintFileField.find_by_dealer_id_and_identifier(params[:dealer][:id], variable).update_attributes(:label => params[variable][:label], :values => params[variable][:values])
      end
    end

    for counter in 1..3
      variable = "text_body_#{counter}"
      unless variables.include?(variable)
         PrintFileField.create(:dealer_id => params[:dealer][:id], :identifier => variable, :label => params[variable][:label],:values => params[variable][:values])
       else
      	 PrintFileField.find_by_dealer_id_and_identifier(params[:dealer][:id], variable).update_attributes(:label => params[variable][:label], :values => params[variable][:values])
       end
     end

     unless variables.include?("template")
     	  PrintFileField.create(:dealer_id =>params[:dealer][:id], :identifier => "template", :label => params[:template],:values => params[:template])
     else
     	  PrintFileField.find_by_dealer_id_and_identifier(params[:dealer][:id], "template").update_attributes(:label => params[:template],:values => params[:template])
     end


     redirect_to  admin_dealer_print_data_path(:dealer_id => dealer.id)
  end

end

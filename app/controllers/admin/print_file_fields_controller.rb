class Admin::PrintFileFieldsController < ApplicationController
  layout 'admin'

  def create
    dealer = Dealer.find(params[:dealer][:id])
    variables = dealer.print_file_fields.map{|rec| rec.identifier}

    for counter in 1..10
      variable = "variable_data_#{counter}"
      unless variables.include?(variable)
         PrintFileField.create(:dealer_id =>dealer.id, :identifier => variable, :label => params[variable][:label],:value => params[variable][:value])
      else
      	 PrintFileField.by_dealer(dealer.id).by_identifier(variable).first.update_attributes(:label => params[variable][:label], :value => params[variable][:value])
      end
    end

    for counter in 1..3
      variable = "text_body_#{counter}"
      unless variables.include?(variable)
         PrintFileField.create(:dealer_id => dealer.id, :identifier => variable, :label => params[variable][:label],:value => params[variable][:value])
       else
      	 PrintFileField.by_dealer(dealer.id).by_identifier(variable).first.update_attributes(:label => params[variable][:label], :value => params[variable][:value])
       end
     end

     unless variables.include?("template")
     	  PrintFileField.create(:dealer_id =>dealer.id, :identifier => "template", :value => params[:template])
     else
     	  PrintFileField.by_dealer(dealer.id).by_identifier("template").first.update_attributes(:value => params[:template])
     end


     redirect_to  admin_dealer_print_data_path(:dealer_id => dealer.id)
  end

end

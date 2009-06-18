class CsvExtraFieldsController < ApplicationController
  before_filter :check_terms_conditions
  before_filter :find_dealer

  def new
    @csv_extra_field = CsvExtraField.new

    ['text_body_1', 'text_body_2', 'text_body_3', 'variable_data_4', 'variable_data_5', 'variable_data_6', 
     'variable_data_7', 'variable_data_8', 'variable_data_9'].map{ |identifier| 
                                                          '@' + identifier = PrintFileField.find_by_dealer_id_and_identifier(current_user.id, identifier)}

    @dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "template")
  end


  def create
  	@csv_extra_field = CsvExtraField.create(:fields => params[:csv_extra_fields],:dealer_id => @dealer.id)
   	variables = @dealer.print_file_fields.map{|rec| rec.identifier}

     for counter in 4..9
     	 variable = "variable_data_#{counter}"
     	 unless variables.include?(variable)
         PrintFileField.create(:dealer_id =>@dealer.id, :identifier => variable, :label => params[variable][:label],:values => params[variable][:values])
       else
      	 PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, variable).update_attributes(:label => params[variable][:label], :values => params[variable][:values])
       end
     end

     unless variables.include?("template")
     	  PrintFileField.create(:dealer_id =>params[:dealer][:id], :identifier => "template", :label => params[:template],:values => params[:template])
     else
     	  PrintFileField.find_by_dealer_id_and_identifier(params[:dealer][:id], "template").update_attributes(:label => params[:template],:values => params[:template])
     end

    respond_to do |format|
      if @csv_extra_field.save
        flash[:notice] = 'CSV Extra Fields was successfully created.'
        format.html { redirect_to(edit_dealer_csv_extra_field_path(@dealer.id)) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
     @fields = @dealer.csv_extra_field.fields
     @text_body_1 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"text_body_1")
     @text_body_2 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"text_body_2")
     @text_body_3 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"text_body_3")
     @variable_data_4 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_4")
     @variable_data_5 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_5")
     @variable_data_6 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_6")
     @variable_data_7 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_7")
     @variable_data_8 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_8")
     @variable_data_9 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "variable_data_9")
     @dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "template")
   end

  def update
    @dealer.csv_extra_field.destroy
    @CsvExtraField = CsvExtraField.create(:fields => params[:csv_extra_fields], :dealer_id => @dealer.id)
    variables = @dealer.print_file_fields.map{|rec| rec.identifier}

     for counter in 4..9
     	 variable = "variable_data_#{counter}"
     	 unless variables.include?(variable)
         PrintFileField.create(:dealer_id =>@dealer.id, :identifier => variable, :label => params[variable][:label],:values => params[variable][:values])
       else
      	 PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, variable).update_attributes(:label => params[variable][:label], :values => params[variable][:values])
       end
     end

     unless variables.include?("template")
     	  PrintFileField.create(:dealer_id =>@dealer.id, :identifier => "template", :label => params[:template],:values => params[:template])
     else
     	  PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "template").update_attributes(:label => params[:template],:values => params[:template])
     end
    respond_to do |format|
      if @CsvExtraField.save
        flash[:notice] = 'CSV Extra Fields was Updated successfully '
        format.html { redirect_to(edit_dealer_csv_extra_field_path(@dealer.id)) }
        format.xml  { render :xml => @CsvExtraField, :status => :created, :location => @dealer }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @CsvExtraField.errors, :status => :unprocessable_entity }
      end
    end

  end

  def print_file_field

 	end


  private

  def find_dealer
  	@dealer = Dealer.find(params[:dealer_id])
  end

  def check_terms_conditions
       if !session[:accept_terms]
       	 redirect_to (:controller =>"sessions" ,:action =>:terms)
       end
 	end

end

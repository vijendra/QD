class Admin::PrintFileFieldsController < ApplicationController
  layout 'admin'


  # GET /admin_print_file_fields/1
  # GET /admin_print_file_fields/1.xml
  def show
    @print_file_field = PrintFileField.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @print_file_field }
    end
  end

  def new
    @print_file_field = PrintFileField.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @print_file_field }
    end
  end


  def edit
    @print_file_field = Admin::PrintFileField.find(params[:id])
  end


  def create
  	 dealer = Dealer.find(params[:dealer][:id])
  	 variables = dealer.print_file_fields.map{|rec| rec.identifier}

     for counter in 4..9
     	 variable = "variable_data_#{counter}"
     	 unless variables.include?(variable)
         PrintFileField.create(:dealer_id =>params[:dealer][:id], :identifier => variable, :label => params[variable][:label],:values => params[variable][:values])
       else
      	 PrintFileField.find_by_dealer_id_and_identifier(params[:dealer][:id], variable).update_attributes(:label => params[variable][:label], :values => params[variable][:values])
       end
     end
     redirect_to  admin_dealer_print_data_path(:dealer_id => dealer.id)
  end

  # PUT /admin_print_file_fields/1
  # PUT /admin_print_file_fields/1.xml
  def update
    @print_file_field = PrintFileField.find(params[:id])

    respond_to do |format|
      if @print_file_field.update_attributes(params[:print_file_field])
        flash[:notice] = 'Admin::PrintFileField was successfully updated.'
        format.html { redirect_to(@print_file_field) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @print_file_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_print_file_fields/1
  # DELETE /admin_print_file_fields/1.xml
  def destroy
    @print_file_field = PrintFileField.find(params[:id])
    @print_file_field.destroy

    respond_to do |format|
      format.html { redirect_to(admin_print_file_fields_url) }
      format.xml  { head :ok }
    end
  end
end

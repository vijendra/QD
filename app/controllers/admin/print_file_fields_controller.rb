class Admin::PrintFileFieldsController < ApplicationController
  # GET /admin_print_file_fields
  # GET /admin_print_file_fields.xml
  def index
    @print_file_fields = PrintFileField.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml =>@print_file_fields }
    end
  end

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
  	 dealer.print_file_fields.map {|print| print.destroy }
     PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_4" ,:label => params[:variable_data_4][:label],:values => params[:variable_data_4][:values])

      PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_5" ,:label => params[:variable_data_5][:label],:values => params[:variable_data_5][:values])

       PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_6" ,:label => params[:variable_data_6][:label],:values => params[:variable_data_6][:values])

        PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_7" ,:label => params[:variable_data_7][:label],:values => params[:variable_data_7][:values])
         PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_8" ,:label => params[:variable_data_8][:label],:values => params[:variable_data_8][:values])
          PrintFileField.create(:dealer_id =>params[:dealer][:id] , :identifier =>"variable_data_9" ,:label => params[:variable_data_9][:label],:values => params[:variable_data_9][:values])


   redirect_to  admin_dealer_print_datas_path(:dealer_id => dealer.id)

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

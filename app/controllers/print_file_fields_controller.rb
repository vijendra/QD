class PrintFileFieldsController < ApplicationController
  before_filter :check_terms_conditions
  before_filter :find_dealer

  def new
    @csv_extra_field = CsvExtraField.new

    ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1','variable_data_2','variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].map {
     |identifier|  instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(current_user.id, identifier)) }
     @dealer_template = PrintFileField.by_dealer(@dealer.id).by_identifier("template").first

  end


  def create
  	@csv_extra_field = CsvExtraField.new(:fields => params[:csv_extra_fields],:dealer_id => @dealer.id)

    respond_to do |format|
      if @csv_extra_field.save
        flash[:notice] = 'CSV Extra Fields was successfully created.'
        format.html { redirect_to(edit_dealer_print_file_field_path(@dealer.id)) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @fields = @dealer.csv_extra_field.fields.blank? ? [] : @dealer.csv_extra_field.fields

    ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1','variable_data_2','variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].map{
     |identifier|  instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(current_user.id, identifier)) }
     @dealer_template = PrintFileField.by_dealer(@dealer.id).by_identifier("template").first

   end

  def update
    @dealer.csv_extra_field.destroy
    @CsvExtraField = CsvExtraField.new(:fields => params[:csv_extra_fields], :dealer_id => @dealer.id)

    respond_to do |format|
      if @CsvExtraField.save
        flash[:notice] = 'CSV Extra Fields was Updated successfully '
        format.html { redirect_to(edit_dealer_print_file_field_path(@dealer.id)) }
        format.xml  { render :xml => @CsvExtraField, :status => :created, :location => @dealer }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @CsvExtraField.errors, :status => :unprocessable_entity }
      end
    end

  end



  private

  def find_dealer
  	@dealer = Dealer.find(params[:dealer_id])
  end

  def check_terms_conditions
     if !logged_in?
  		 redirect_to(login_url)
  	elsif !session[:accept_terms]
    	redirect_to(:controller =>"sessions" ,:action =>:terms)
    end
 	end

end

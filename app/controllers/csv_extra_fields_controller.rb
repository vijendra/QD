class CsvExtraFieldsController < ApplicationController
  before_filter :check_terms_conditions
 before_filter :find_dealer

  def new
      @csv_extra_field = CsvExtraField.new
  	  respond_to do |format|
  	  	format.html
  		 format.js { render :layout => false }
  	  end

  end

  def create
  	@csv_extra_field = CsvExtraField.create(:fields => params[:csv_extra_fields],:dealer_id => @dealer.id)
    respond_to do |format|
      if @csv_extra_field.save
        flash[:notice] = 'CSV Extra Fields was successfully created.'
        format.html { redirect_to("/dashboard/index") }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  	 @fields = @dealer.csv_extra_field.fields
  	 respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def update
    @dealer.csv_extra_field.destroy
    @CsvExtraField = CsvExtraField.create(:fields => params[:csv_extra_fields], :dealer_id => @dealer.id)
    respond_to do |format|
      if @CsvExtraField.save
        flash[:notice] = 'CSV Extra Fields was Updated successfully '
        format.html { redirect_to("/dashboard/index") }
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
       if !session[:accept_terms]
       	 redirect_to (:controller =>"sessions" ,:action =>:terms)
       end
 	end

end

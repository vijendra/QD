class DealersController < ApplicationController
  # GET /dealers
  # GET /dealers.xml
  def index
    @dealers = Dealer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealers }
    end
  end

  # GET /dealers/1
  # GET /dealers/1.xml
  def show
    @dealers = Dealer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dealers }
    end
  end

  # GET /dealers/new
  # GET /dealers/new.xml
  def new
    @dealers = Dealer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dealers }
    end
  end

  # GET /dealers/1/edit
  def edit
    @dealers = Dealer.find(params[:id])
  end

  # POST /dealers
  # POST /dealers.xml
  def create
    @dealers = Dealer.new(params[:dealers])

    respond_to do |format|
      if @dealers.save
        flash[:notice] = 'Dealers was successfully created.'
        format.html { redirect_to(@dealers) }
        format.xml  { render :xml => @dealers, :status => :created, :location => @dealers }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealers.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dealers/1
  # PUT /dealers/1.xml
  def update
    @dealers = Dealer.find(params[:id])

    respond_to do |format|
      if @dealers.update_attributes(params[:dealers])
        flash[:notice] = 'Dealers was successfully updated.'
        format.html { redirect_to(@dealers) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dealers.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dealers/1
  # DELETE /dealers/1.xml
  def destroy
    @dealers = Dealer.find(params[:id])
    @dealers.destroy

    respond_to do |format|
      format.html { redirect_to(dealers_url) }
      format.xml  { head :ok }
    end
  end

  def csv_extra_field_new
      @dealer = Dealer.find(params[:id])
  	  @csv_extra_field = CsvExtraField.new
  	  respond_to do |format|
  	  	format.html
  		 format.js { render :layout => false }
  	  end

  end

  def csv_extra_field_create
  	 @dealer = Dealer.find(params[:id])
  	 @csv_extra_field = CsvExtraField.create(:fields => params[:csv_extra_fields],:dealer_id => @dealer.id)

    respond_to do |format|
      if @csv_extra_field.save
        flash[:notice] = 'CSV Extra Fields was successfully created.'
        format.html { redirect_to(dealers_url) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  def csv_extra_field_edit
  	 @dealer = Dealer.find(params[:id])
  	 @fields = @dealer.csv_extra_field.fields
  	 respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def csv_extra_field_update
    @dealer = Dealer.find(params[:id])
    @dealer.csv_extra_field.destroy
    @CsvExtraField = CsvExtraField.create(:fields => params[:csv_extra_fields], :dealer_id => @dealer.id)
    respond_to do |format|
      if @CsvExtraField.save
        flash[:notice] = 'CSV Extra Fields was Updated successfully '
        format.html { redirect_to(dealers_url) }
        format.xml  { render :xml => @CsvExtraField, :status => :created, :location => @dealer }
      else
        format.html { render :action => "csv_extra_field_edit" }
        format.xml  { render :xml => @CsvExtraField.errors, :status => :unprocessable_entity }
      end
    end

  end


end

class Admin::DealersController < ApplicationController
  require_role :admin
  layout 'admin'
  require 'fastercsv'

  def index
    @dealers = Dealer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealer }
    end
  end

  # GET /dealers/1
  # GET /dealers/1.xml
  def show
    @dealer = Dealer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dealer }
    end
  end

  # GET /dealers/new
  # GET /dealers/new.xml
  def new
    @dealer = Dealer.new
    @dealer.build_profile
    @dealer.build_address
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dealer }
    end
  end

  # GET /dealers/1/edit
  def edit
    @dealer = Dealer.find(params[:id])
  end

  # POST /dealers
  # POST /dealers.xml
  def create
    @dealer = Dealer.new(params[:dealer])

    respond_to do |format|
      if @dealer.save
        flash[:notice] = 'Dealer was successfully created.'
        format.html { redirect_to(@dealer) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dealers/1
  # PUT /dealers/1.xml
  def update
    @dealer = Dealer.find(params[:id])

    respond_to do |format|
      if @dealer.update_attributes(params[:dealers])
        flash[:notice] = 'Dealer was successfully updated.'
        format.html { redirect_to(@dealer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dealer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dealers/1
  # DELETE /dealers/1.xml
  def destroy
    @dealer = Dealer.find(params[:id])
    @dealer.destroy

    respond_to do |format|
      format.html { redirect_to(admin_dealers_url) }
      format.xml  { head :ok }
    end
  end

  def csv_import
    data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(params[:dealer][:file].path, :headers => :false) do |row|
      data_set = {:dealer_id => params[:dealer_id]}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end

    flash[:notice] = 'CSV data is successfully imported.'
    redirect_to(admin_dealers_url)
  end
   def dealer_fields_new
      @dealer = Dealer.find(params[:id])
  	  @dealer_field = DealerField.new
  	  respond_to do |format|
  	  	format.html
  		 format.js { render :layout => false }
  	  end

  end

  def dealer_fields_create
  	 @dealer = Dealer.find(params[:id])
  	 @dealer_field = @dealer.dealer_field.create(:fields => params[:dealer_fields])


    respond_to do |format|
      if @dealer_field.save
        flash[:notice] = 'Dealer Fields was successfully created.'
        format.html { redirect_to(admin_dealers_url) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "dealer_fields_new" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end


end

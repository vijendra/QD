class Admin::DealersController < ApplicationController
  require_role :admin
  layout 'admin'
  require 'fastercsv'

  def index
    @search = Dealer.new_search(params[:search])
    @search.per_page ||=10
    @dealers = @search.all

   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealer }
      format.js {  render :update do |page|
      	            page.replace_html 'dealer-list', :partial => 'dealers_list'
     	           end
      	        }
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
        @dealer.register!
        @dealer.activate!
        flash[:notice] = 'Dealer was successfully created.'
        format.html { redirect_to(admin_dealers_path)}
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @dealer = Dealer.find(params[:id])
    respond_to do |format|
      if @dealer.update_attributes(params[:dealer])
        flash[:notice] = 'Dealer was successfully updated.'
        format.html { redirect_to(admin_dealers_path) }
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
    @dealer.profile.destroy
    @dealer.address.destroy
    @dealer.destroy

    respond_to do |format|
      format.html { redirect_to(admin_dealers_url) }
      format.xml  { head :ok }
    end
  end

  def csv
  	@dealer = Dealer.find(params[:id])
  	render :lauout =>"false"
 	end

  def csv_import
    dealer = Dealer.find(params[:dealer_id])
    balance = dealer.profile.current_balance

    data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(params[:dealer][:file].path, :headers => :false) do |row|
      balance = balance -1
      data_set = {:dealer_id => params[:dealer_id]}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end

    dealer.profile.update_attribute('current_balance', balance)
    flash[:notice] = 'CSV data is successfully imported.'

    redirect_to(admin_dealers_url)
  end


   def reset_password
    @dealer = Dealer.find(params[:id])
    @dealer.reset_password!
    flash[:notice] = "A new password has been sent to the Dealer by email."
    redirect_to edit_admin_dealer_path(@dealer)
  end

 def inactive
    @dealer = Dealer.find(params[:id])
    @dealer.suspend!
    redirect_to admin_dealers_path
  end

  def active
    @dealer = Dealer.find(params[:id])
    @dealer.unsuspend!
    redirect_to admin_dealers_path
  end


  def assign_administrator
    @dealer = Dealer.find(params[:id])
    unless (params[:administrator].blank? || params[:administrator][:id].blank?)
      profile = @dealer.profile
      profile.administrator_id = params[:administrator][:id]
      profile.save
      redirect_to admin_dealers_url
  	else
  	  render :layout => false
   	end
 	end





end

class DealersController < ApplicationController
  before_filter :check_terms_conditions
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
        format.html { redirect_to(dealers_url) }
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
private

  def check_terms_conditions
       if !session[:accept_terms]
       	 redirect_to (:controller =>"sessions" ,:action =>:terms)
       end
 	end



end

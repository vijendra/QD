class DealersController < ApplicationController
  before_filter :check_terms_conditions

  def index
    @dealers = Dealer.all
  end

  def show
    @dealers = Dealer.find(params[:id])
  end

  def new
    @dealers = Dealer.new
  end

  def edit
    @dealers = Dealer.find(params[:id])
  end

  def create
    @dealers = Dealer.new(params[:dealers])
    respond_to do |format|
      if @dealers.save
        flash[:notice] = 'Dealers was successfully created.'
        format.html { redirect_to(@dealers) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @dealers = Dealer.find(params[:id])
    respond_to do |format|
      if @dealers.update_attributes(params[:dealers])
        flash[:notice] = 'Dealers was successfully updated.'
        format.html { redirect_to(dealers_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @dealers = Dealer.find(params[:id])
    @dealers.destroy
    redirect_to(dealers_url)
  end

private

  def check_terms_conditions
  	if !logged_in?
  		 redirect_to(:controller => :session ,:action => :new)
  	elsif !session[:accept_terms]
    	redirect_to(:controller =>"sessions" ,:action =>:terms)
    end
 	end
end

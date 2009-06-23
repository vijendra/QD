class Admin::DealerFieldsController < ApplicationController
  before_filter :find_dealer

  def new
  	@dealer_field = DealerField.new
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def edit
     @fields = @dealer.dealer_field.fields
  	 respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
   @dealer_field = DealerField.create(:fields => params[:dealer_fields], :dealer_id => @dealer.id)
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

  def update
    @dealer.dealer_field.destroy
    @dealer_field = DealerField.create(:fields => params[:dealer_fields], :dealer_id => @dealer.id)
    respond_to do |format|
      if @dealer_field.save
        flash[:notice] = 'Dealer Fields was Updated successfully '
        format.html { redirect_to(admin_dealers_url) }
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "dealer_fields_edit" }
        format.xml  { render :xml => @dealer_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

   def find_dealer
  	 @dealer = Dealer.find(params[:dealer_id])
   end
 end

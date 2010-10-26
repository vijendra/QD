class Admin::DataAppendsController < ApplicationController
 layout 'admin'
  
  def index
    @search = DataAppend.new_search(params[:search])
    @search.per_page ||= 5
    @search.page ||= 1
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"
    @search.include = [[:dealer], [:requestor]]
    @search.conditions.requestor_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')
    @data_appends =  @search.all
  end

  def show
    @data_append = DataAppend.find(params[:id])
  end

 
  def new
    @data_append =  DataAppend.new
  end

 
  def edit
    @data_append =  DataAppend.find(params[:id])
  end


  def create
    if params[:product_types].blank?
      flash[:error] = "Records can't be sent for append. You must select append product type."
      redirect_to :back
    else
      @data_append = DataAppend.new(params[:data_append])
      if @data_append.save
        redirect_to(:back, :notice => 'Data is successfully sent for append. Please check the results after 10 minutes.')  
      else
        #Display exception
        flash[:error] = @data_append.each_full {|msg| msg}.join("<br />")
        redirect_to :back
      end  
    end
  end
end

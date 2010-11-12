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
    if params[:data_append][:tid_list].blank? 
      flash[:error] = "Records can't be sent for append. You must select records to be sent for append."
      redirect_to :back
    else
      success = true
      #For each product type create one append request record
      params[:data_append][:tid_list].each do |tid|
        trigger = TriggerDetail.find(tid)
        @data_append = DataAppend.new(params[:data_append].merge({:no_of_records => trigger.total_records, :dealer_id => trigger.dealer_id, :tid => tid}))
        unless @data_append.save
          success = true
        end  
      end
        
      if success
        redirect_to(:back, :notice => 'Data is successfully sent for append. Please check the results after 10 minutes.')
      else
        #Display exception
        flash[:error] = "There was some problem in sending few records for append. Please check append requests list for successfully sent records"
        redirect_to :back     
      end
    end   
  end
  
=begin
  def create
    #if params[:data_append][:product_types].blank?
      #flash[:error] = "Records can't be sent for append. You must select atleast one append product type."
      #redirect_to :back
    #elsif params[:data_append][:tid_list].blank?
    if params[:data_append][:tid_list].blank? 
      flash[:error] = "Records can't be sent for append. You must select records to be sent for append."
      redirect_to :back
    else
      #For each product type create one append request record
      #params[:data_append][:product_types].each do |p|
        #@data_append = DataAppend.new(params[:data_append].merge({:product => p}))
        params[:data_append][:tid_list].each do |tid|
          trigger = Trigger.find(params[:tid])
          @data_append = DataAppend.new(params[:data_append].merge({:no_of_records => trigger.total_records, :dealer_id => trigger.dealer_id}))
          if @data_append.save
            redirect_to(:back, :notice => 'Data is successfully sent for append. Please check the results after 10 minutes.')  
          else
            #Display exception
            flash[:error] = @data_append.each_full{|msg| msg}.join("<br />")
            redirect_to :back
          end  
      #end  
    end
  end
=end  
end

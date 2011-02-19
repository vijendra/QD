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
 
  def create
    if params[:data_append].has_key?('tid_list')
      params[:data_append][:tid_list].each do |tid|
        trigger = TriggerDetail.find(tid)
        @data_append = DataAppend.new(params[:data_append].merge({:no_of_records => trigger.total_records, :dealer_id => trigger.dealer_id, :tid => tid, :requestor_id => current_user.id, :status_message =>  'sent' }))
        unless @data_append.save
          flash[:error] = "Few records coudln't be sent for append. Please check the append request list and send pending records again." + "<br />" + @data_append.errors.full_messages.join("< br/>") 
          redirect_to :back  
        end   
      end
      redirect_to :back, :notice => "Data is successfully sent for append. Please check the results after 5 minutes." 
    else
      flash[:error] = "No data selected for append."
      redirect_to :back
    end  
  end
  
  def ncoa_append
    pending_appends = DataAppend.pending_ncoa_appends
    success = true
    unless pending_appends.blank?
      pending_appends.each do |append|
        unless append.send_for_append
          success = false
        end
      end
    end
    flash[:notice] = "Data is successfully sent for ncoa append. Please check the results after 5 minutes." if success
    flash[:error] = "There was some problem in sending records for append. Please try again." unless success
    redirect_to :back
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

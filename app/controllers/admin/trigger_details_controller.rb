class Admin::TriggerDetailsController < ApplicationController
  layout 'admin'
  require_role 'super_admin'
  def index

    @search = TriggerDetail.new_search(params[:search])
    @search.per_page ||= 15
    @search.page ||= 1
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"

    unless params[:today].blank?
      @search.conditions.created_at_after = Time.now.beginning_of_day()
       params[:today] = nil
    end
    unless params[:created_at].blank?
    	 date = Time.parse(params[:created_at])
         @search.conditions.created_at_after = date.beginning_of_day()
    	 @search.conditions.created_at_before =  date.end_of_day()
   	end
    @triggers = @search.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealer }
      format.js {  render :update do |page|
      	            page.replace_html 'trigger-list', :partial => 'trigger_details_list'
     	           end
      	        }
    end
  end
end

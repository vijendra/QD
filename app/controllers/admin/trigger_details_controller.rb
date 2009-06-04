class Admin::TriggerDetailsController < ApplicationController
  layout 'admin'
  require_role 'super_admin'
  def index

    @search = TriggerDetail.new_search(params[:search])
    @search.per_page ||=10
    @search.conditions.created_at = Date.today if params[:created_at].blank?
    unless params[:created_at].blank?
    	 date = params[:created_at].to_date
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

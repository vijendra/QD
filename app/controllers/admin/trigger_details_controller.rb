class Admin::TriggerDetailsController < ApplicationController
  layout 'admin'
  require_role 'super_admin'
  def index

    @search = TriggerDetail.new_search(params[:search])
    @search.per_page ||=10
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

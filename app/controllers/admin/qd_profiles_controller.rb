class Admin::QdProfilesController < ApplicationController
  require_role :admin
  layout 'admin'

  def index

  	@search = QdProfile.new_search(params[:search])
    @search.per_page ||= 15
   unless params[:today].blank?
       @search.conditions.created_at = Date.today
       params[:today] = nil
    end

    unless params[:created_at].blank?
    	 date = params[:created_at].to_date
         @search.conditions.created_at_after = date.beginning_of_day()
    	 @search.conditions.created_at_before =  date.end_of_day()
   	end
    unless params[:name].blank?
      group1 = @search.conditions.group
      group1.fname_like = params[:name]
      group1.or_lname_like = params[:name]
    end
   	@qd_profiles = @search.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @qd_profiles }
      format.js  {  render :update do |page|
      	              page.replace_html 'qd_profile-list', :partial => 'qd_profiles_list'
     	            end
      	         }
    end
  end



end

class Admin::QdProfilesController < ApplicationController
  require_role :admin
  layout 'admin'

  def index
    @search = QdProfile.new_search(params[:search])
    @search.per_page ||= 2
    @qd_profiles = @search.all

   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @qd_profiles }
      format.js {  render :update do |page|
      	            page.replace_html 'qd_profile-list', :partial => 'qd_profiles_list'
     	           end
      	        }
    end
 end



end

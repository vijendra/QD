class Admin::QdProfilesController < ApplicationController
  require_role :admin
  layout 'admin'

  def index
    @qd_profiles = QdProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @qd_profiles }
    end
  end
end

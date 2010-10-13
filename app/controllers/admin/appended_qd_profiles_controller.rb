class Admin::AppendedQdProfilesController < ApplicationController
  # GET /admin_appended_qd_profiles
  # GET /admin_appended_qd_profiles.xml
  def index
    @admin_appended_qd_profiles = Admin::AppendedQdProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_appended_qd_profiles }
    end
  end

  # GET /admin_appended_qd_profiles/1
  # GET /admin_appended_qd_profiles/1.xml
  def show
    @appended_qd_profile = Admin::AppendedQdProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @appended_qd_profile }
    end
  end

  # GET /admin_appended_qd_profiles/new
  # GET /admin_appended_qd_profiles/new.xml
  def new
    @appended_qd_profile = Admin::AppendedQdProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @appended_qd_profile }
    end
  end

  # GET /admin_appended_qd_profiles/1/edit
  def edit
    @appended_qd_profile = Admin::AppendedQdProfile.find(params[:id])
  end

  # POST /admin_appended_qd_profiles
  # POST /admin_appended_qd_profiles.xml
  def create
    @appended_qd_profile = Admin::AppendedQdProfile.new(params[:appended_qd_profile])

    respond_to do |format|
      if @appended_qd_profile.save
        format.html { redirect_to(@appended_qd_profile, :notice => 'Admin::AppendedQdProfile was successfully created.') }
        format.xml  { render :xml => @appended_qd_profile, :status => :created, :location => @appended_qd_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @appended_qd_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_appended_qd_profiles/1
  # PUT /admin_appended_qd_profiles/1.xml
  def update
    @appended_qd_profile = Admin::AppendedQdProfile.find(params[:id])

    respond_to do |format|
      if @appended_qd_profile.update_attributes(params[:appended_qd_profile])
        format.html { redirect_to(@appended_qd_profile, :notice => 'Admin::AppendedQdProfile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @appended_qd_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_appended_qd_profiles/1
  # DELETE /admin_appended_qd_profiles/1.xml
  def destroy
    @appended_qd_profile = Admin::AppendedQdProfile.find(params[:id])
    @appended_qd_profile.destroy

    respond_to do |format|
      format.html { redirect_to(admin_appended_qd_profiles_url) }
      format.xml  { head :ok }
    end
  end
end

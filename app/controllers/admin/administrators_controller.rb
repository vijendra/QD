class Admin::AdministratorsController < ApplicationController
  require_role :admin
  layout 'admin'


  def index
    @administrators = Administrator.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administrator }
    end
  end


  def show
    @administrator = Administrator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @administrator }
    end
  end


  def new
    @administrator = Administrator.new
    @administrator.build_administrator_profile
    @administrator.build_address
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administrator }
    end
  end


  def edit
    @administrator = Administrator.find(params[:id])
  end


  def create
    @administrator = Administrator.new(params[:administrator])

    respond_to do |format|
      if @administrator.save

      	@administrator.register!
        @administrator.activate!
        flash[:notice] = 'Administrator was successfully created.'
        format.html { redirect_to(admin_administrators_url) }
        format.xml  { render :xml => @administrator, :status => :created, :location => @administrator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administrator.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @administrator = Administrator.find(params[:id])

    respond_to do |format|
      if @administrator.update_attributes(params[:administrator])
        flash[:notice] = 'Administrator was successfully updated.'
        format.html { redirect_to(admin_administrator_path(@administrator) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administrator.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @administrator = Administrator.find(params[:id])
    @administrator.destroy

    respond_to do |format|
      format.html { redirect_to(admin_administrators_url) }
      format.xml  { head :ok }
    end
  end

  def activate
    @administrator = Administrator.find(params[:id])
    @administrator.activate!
    redirect_to admin_administrators_path
  end

  def suspend
    @administrator = Administrator.find(params[:id])
    @administrator.suspend!
    redirect_to admin_administrators_path
  end

  def unsuspend
    @administrator = Administrator.find(params[:id])
    @administrator.unsuspend!
    redirect_to admin_administrators_path
  end

  def purge
    @administrator = Administrator.find(params[:id])
    @administrator.destroy
    redirect_to admin_administrators_url
  end

  def reset_password
    @administrator = Administrator.find(params[:id])
    @administrator.reset_password!
    flash[:notice] = "A new password has been sent to the administrator by email."
    redirect_to admin_administrator_path(@administrator)
  end

end

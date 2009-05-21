class Admin::AdministratorsController < ApplicationController
  require_role :super_admin
  layout 'admin'

  def index
    @administrators = Administrator.all
  end


  def show
    @administrator = Administrator.find(params[:id])
  end


  def new
    @administrator = Administrator.new
    @administrator.build_administrator_profile
    @administrator.build_address
  end


  def edit
    @administrator = Administrator.find(params[:id])
  end

  def create
    @administrator = Administrator.new(params[:administrator])
      
    if @administrator.save
      @administrator.register!
      @administrator.activate!
      flash[:notice] = 'Administrator was successfully created.'
      redirect_to(admin_administrators_url)
    else
      render :action => "new"
    end

  end

  def update
    @administrator = Administrator.find(params[:id])

      if @administrator.update_attributes(params[:administrator])
        flash[:notice] = 'Administrator was successfully updated.'
        redirect_to(admin_administrator_path(@administrator) )
      else
        render :action => "edit"  
      end
  end


  def destroy
    @administrator = Administrator.find(params[:id])
    @administrator.destroy
    redirect_to(admin_administrators_url)
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

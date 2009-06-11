class Admin::AdministratorsController < ApplicationController

   require_role ["super_admin", "admin"]
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
    if @administrator.disclaimer_content.blank?
    	 disclaimer_content = AdminSetting.find_by_identifier("disclaimer_content")
    	 @admin_disclaimer_content = DisclaimerContent.new( :administrator_id => @administrator.id ,
    	                                                    :values => disclaimer_content.values )
    	 @admin_disclaimer_content.save
    else
       @admin_disclaimer_content = @administrator.disclaimer_content
   	end
  end

  def create
    @administrator = Administrator.new(params[:administrator])

    if @administrator.save
      @administrator.register!
      @administrator.activate!
      @administrator.roles << Role.find_by_name('admin')
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

  def disclaimer_content_save

    disclaimer_content = DisclaimerContent.find(params[:admin_disclaimer_content][:id])
    disclaimer_content.update_attributes(:values => params[:admin_disclaimer_content][:values])
     redirect_to(edit_admin_administrator_url(:id => params[:administrator][:id]))
 	end

end

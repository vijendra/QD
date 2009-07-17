class Admin::AdministratorsController < ApplicationController

   require_role "super_admin"
   before_filter :check_role
   layout 'admin'
   
    %w(email login).each do |attr|
    in_place_edit_for :administrator, attr.to_sym
  end

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


   def dispaly_administrator_setting

    @administrator  =  Administrator.find(params[:id])

    @administrator_setting = AdministratorSetting.by_administrator_and_identifier(@administrator.id,params[:identifier]).first

    if @administrator_setting.blank?
    	application_setting = ApplicationSetting.find_by_identifier(params[:identifier])
    	@administrator_setting = AdministratorSetting.create(:administrator_id => @administrator.id , :identifier => params[:identifier] ,:value => application_setting.value )
    end
    if params[:identifier] =~ /mail/
    	 @subject = AdministratorSetting.by_administrator_and_identifier(@administrator.id,"#{params[:identifier]}_subject").first
       if @subject.blank?
       	 app_setting = ApplicationSetting.find_by_identifier("#{params[:identifier]}_subject")
       	 @subject = AdministratorSetting.create(:administrator_id => @administrator.id , :identifier => "#{params[:identifier]}_subject" ,:value => app_setting.value )
       end
    end
    render :update do |page|
      page.replace_html 'administrator_settings', :partial => 'admin/administrators/administrator_settings'
    end
  end


   def update_administrator_setting
     @administrator_setting  = AdministratorSetting.find(params[:administrator_setting][:id])
     administrator = Administrator.find(params[:administrator][:id])
     @administrator_setting.update_attributes(params[:administrator_setting])
     unless params[:subject].blank?
       @subject = AdministratorSetting.find(params[:subject][:id])
       @subject.update_attributes(:administrator_id =>administrator.id ,:value => params[:subject][:value])
     end
     flash[:notice] = "#{@administrator_setting.identifier.humanize} succeefully updated"
     redirect_to(edit_admin_administrator_url(administrator))
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


 	private

 	def check_role
 		if admin? and !session[:accept_terms]
    	 redirect_to(:controller =>"/sessions" ,:action =>:terms)
    end
	end

  def admin?
    logged_in? && current_user.has_role?(:admin)
  end
end

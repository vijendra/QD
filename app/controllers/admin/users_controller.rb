class Admin::UsersController < ApplicationController
  before_filter :check_login
  require_role :super_admin
  layout 'admin'

  %w(email login).each do |attr|
    in_place_edit_for :user, attr.to_sym
  end

  def reset_password
    @user = User.find(params[:id])
    @user.reset_password!

    flash[:notice] = "A new password has been sent to the user by email."
    redirect_to admin_user_path(@user)
  end

  def pending
    @users = User.paginate :all, :conditions => {:state => 'pending'}, :page => params[:page]
    render :action => 'index'
  end

  def suspended
    @users = User.paginate :all, :conditions => {:state => 'suspended'}, :page => params[:page]
    render :action => 'index'
  end

  def active
    @users = User.paginate :all, :conditions => {:state => 'active'}, :page => params[:page]
    render :action => 'index'
  end

  def deleted
    @users = User.paginate :all, :conditions => {:state => 'deleted'}, :page => params[:page]
    render :action => 'index'
  end

  def activate
    @user = User.find(params[:id])
    @user.activate!
    redirect_to admin_users_path
  end

  def suspend
    @user = User.find(params[:id])
    @user.suspend!
    redirect_to admin_users_path
  end

  def unsuspend
    @user = User.find(params[:id])
    @user.unsuspend!
    redirect_to admin_users_path
  end

  def purge
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_url
  end

  # DELETE /admin_users/1
  # DELETE /admin_users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.delete!

    redirect_to admin_users_path
  end

  # GET /admin_users
  # GET /admin_users.xml
  def index
    role = Role.find_by_name(params[:role])
    @users = role.users unless role.blank?
    #@users = User.paginate(:all, :joins => 'roles', :conditions => :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin_users/1
  # GET /admin_users/1.xml
  def show
    @user = User.find(params[:id])
  #    @user.build_site_image unless @user.site_image.blank?
      @site_image = SiteImage.find(:first)

        respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /admin_users/new
  # GET /admin_users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # POST /admin/users
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.register!
        flash[:notice] = "User was successfully created."
        format.html { redirect_to(admin_user_url(@user)) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_application_setting
     @application_setting  = ApplicationSetting.find(params[:application_setting][:id])
     @user = User.find(params[:user][:id])
     @application_setting.update_attributes(params[:application_setting])
     unless params[:subject].blank?
       @subject = ApplicationSetting.find(params[:subject][:id])
       @subject.update_attributes(:value => params[:subject][:value])
     end
     flash[:notice] = "#{@application_setting.identifier.humanize} succeefully updated"
     redirect_to(admin_user_path(@user))
  end

  def update
     @user =  User.find(params[:id])
  end

  def dispaly_application_setting
    @user =  User.find(params[:id])
    @application_setting = ApplicationSetting.find_or_create_by_identifier(params[:identifier])
    @subject = ApplicationSetting.find_or_create_by_identifier("#{params[:identifier]}_subject") if params[:identifier] =~ /mail/
    render :update do |page|
      page.replace_html 'application_settings', :partial => 'admin/users/application_settings'
    end
  end

  def user_image
  	@user = User.find(params[:id])
    site_image = SiteImage.find_or_create_by_id(1)
    site_image.update_attributes(:site_image => params[:site_image][:site_image])
  	redirect_to(admin_user_path(@user))
 	end




end


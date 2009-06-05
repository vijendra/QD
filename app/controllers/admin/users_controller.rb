class Admin::UsersController < ApplicationController
  require_role :admin
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
    @admin_setting = AdminSetting.find_or_create_by_identifier("dynamic_content")

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

    def admin_setting
   	  @admin_setting  =AdminSetting.find_by_identifier("dynamic_content")
   	  @user = User.find(params[:user][:id])
   	  @admin_setting.update_attributes(params[:admin_setting])

   	  redirect_to(admin_user_path(@user))
   	end

  def update
      @user =  User.find(params[:id])
 	end
end

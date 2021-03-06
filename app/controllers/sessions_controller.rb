# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create,:destroy,:accept_terms]

  layout 'login'

  def new

  end

  def create
     logout_keeping_session!
     if using_open_id?
       open_id_authentication
     else
       password_authentication
     end
  end

  def destroy
    logout_killing_session!
    session[:accept_terms] = nil
 
    redirect_back_or_default(root_path)
  end

  def open_id_authentication
    authenticate_with_open_id(params[:openid_url], :required => [:nickname, :email]) do |result, identity_url|
      if result.successful? && self.current_user = User.find_by_identity_url(identity_url)
        successful_login
      else
        flash[:error] = result.message || "Sorry no user with that identity URL exists"
        @rememer_me = params[:remember_me]
        render :action => :new
      end
    end
  end

  def terms
    unless (super_admin? or admin? )
      @disclaimer_content = AdministratorSetting.find_by_administrator_id(current_user.administrator_id).value rescue ''
      @disclaimer_content = @disclaimer_content.blank?? (ApplicationSetting.find_by_identifier("disclaimer_content").value rescue '') : @disclaimer_content
    end
  end

  def accept_terms
  	if params[:commit] == 'Agree'
      redirect_to(qd_profiles_url)
      session[:accept_terms] = true
    else
    	flash[:error] = "Please accept the terms and conditions."
    	@disclaimer_content = ApplicationSetting.find_by_identifier('disclaimer_content').values rescue ' '
    	redirect_to(:controller =>:sessions ,:action =>:terms)
    end
 	end

  protected

  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_user = user
      successful_login
    else
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      render :action => :new
    end
  end

  def successful_login
    # It's possible to use OpenID only, in which
    # case the following would update a user's email and nickname
    # on login.
    #
    # This may give conflicts when used in combination with regular
    # user accounts.
    #
    # TODO: Add a configuration option to disable regular accounts.
    #
    # current_user.update_attributes(
    #   :login => "#{params[:openid.sreg.nickname]}",
    #   :email => "#{params[:openid.sreg.email]}"
    # )

    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    unless (super_admin? || admin?)
    	redirect_to(:controller => :sessions ,:action =>:terms)
    else
     	session[:accept_terms] = true
     	if super_admin?
     	   redirect_back_or_default(dashboard_path) 
   	  else
        redirect_to(admin_qd_profiles_url)
      end 
      
   end
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

 	private
 	def super_admin?
      logged_in? && (current_user.roles.map{|role| role.name}).include?('super_admin')
  end
   def admin?
    logged_in? && current_user.has_role?(:admin)
  end
end

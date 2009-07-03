class ProfilesController < ApplicationController
  before_filter :find_profile
  before_filter :check_terms_conditions
  before_filter :check_owner_access, :only => [:edit, :update]

  def show
    # render show.html.erb
  end

  def edit

  end

  def update
    unless @profile.nil?
      @profile.update_attributes(params[:profile])
      @address.update_attributes(params[:address])
      flash[:notice] = "Your profile has been succesfully updated."
      redirect_to profile_url(@profile.user)
    else
      render :edit
    end
  end

  protected

  def find_profile
    begin
      @user = User.find(params[:id])
    rescue
      @user = nil
    end
    @profile = @user.nil? ? nil : @user.profile
    @address = @user.nil? ? nil : @user.address
  end

  def check_owner_access
    redirect_to profile_url(params[:id]) if logged_in? && current_user != @user
  end
  private
  private

  def check_terms_conditions
    if !logged_in?
  		 redirect_to(login_url)
  	elsif !session[:accept_terms]
    	redirect_to(:controller =>"sessions" ,:action =>:terms)
    end
 	end
end

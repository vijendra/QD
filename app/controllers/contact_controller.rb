class ContactController < ApplicationController
	before_filter :check_logged_in

  def super_admin_contact
  	@user = User.find(126)
  	#render :lauout =>"false"
  end

  def administrator_contact
  	@administrator = Administrator.find(current_user.administrator_id) unless current_user.administrator_id.blank?
  	#render :lauout =>"false"
  end

  private

   def check_logged_in
   	  unless logged_in?
   	 	  redirect_to (login_url )
  	  end
   end

end

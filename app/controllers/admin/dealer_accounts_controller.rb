class Admin::DealerAccountsController < ApplicationController
  before_filter :check_login
  before_filter :find_dealer
  require_role 'super_admin'

  def index
     @trigger_details = @dealer.trigger_details
     @account_resets = @dealer.account_resets.by_date_filter
  end

  def new
    profile = @dealer.profile
    profile.update_attributes(:starting_balance => params[:start_balance], :current_balance => profile.current_balance.to_i + params[:start_balance].to_i )

    AccountReset.create(:dealer_id => @dealer.id , :user_id => current_user.id , :unit => params[:start_balance] ,:rate => @dealer.profile.rate)

    flash[:notice] = "Starting balance reset is done successfully"
    redirect_to admin_dealer_dealer_accounts_path(@dealer)
  end

  def edit_profile_rate
  	@dealer.profile.update_attributes(:rate => params[:rate])
  	flash[:notice] = "Rate is Updated Successfully "
    redirect_to admin_dealer_dealer_accounts_path(@dealer)
 	end

  private
    def find_dealer
    	@dealer = Dealer.find(params[:dealer_id])
    end

end


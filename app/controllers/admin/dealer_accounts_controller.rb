class Admin::DealerAccountsController < ApplicationController
  before_filter :find_dealer


  def index
     @trigger_details = @dealer.trigger_details
  end

  def new
    profile = @dealer.profile
    profile.update_attributes(:starting_balance => params[:start_balance], :current_balance => profile.current_balance.to_i + params[:start_balance].to_i )
    flash[:notice] = "Starting balance reset is done successfully"
    redirect_to admin_dealer_dealer_accounts_path(@dealer)
  end

  private
    def find_dealer
    	@dealer = Dealer.find(params[:dealer_id])
    end

end

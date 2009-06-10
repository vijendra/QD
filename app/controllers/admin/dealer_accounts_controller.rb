class Admin::DealerAccountsController < ApplicationController
	before_filter :find_dealer


  def index
  	@trigger_details = @dealer.trigger_details
  end

  private
    def find_dealer
    	@dealer = Dealer.find(params[:dealer_id])
    end

end

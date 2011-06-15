class Admin::DncNumbersController < ApplicationController
  before_filter :check_login
  def index
    @search = QdProfile.new_search()
    @search.include = [:dealer]
    @search.conditions.dealer.administrator_id = current_user.id unless (current_user.roles.map{|role| role.name}).include?('super_admin')
    @search.conditions.dnc = true
    @qd_profiles = @search.all
  end
end


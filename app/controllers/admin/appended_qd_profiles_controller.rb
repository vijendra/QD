class Admin::AppendedQdProfilesController < ApplicationController
  before_filter :check_login
  def index
    @data_append = DataAppend.find(params[:data_append_id], :include => :qd_profiles)
    @appended_qd_profiles = @data_append.appended_qd_profiles
  end

end


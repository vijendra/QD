class Admin::QdProfilesController < ApplicationController
  require_role :admin
  layout 'admin'
  require 'fastercsv'
  before_filter :check_role

  def index
    @search = QdProfile.new_search(params[:search])
    @params = params[:search]
    @search.per_page ||= 15
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"

    unless params[:today].blank?
       if params[:today] == "1"
       	 @search.conditions.created_at_like = Date.today
      else
         @search.conditions.created_at_like = Date.yesterday
      end
      params[:today] = nil
    end

    unless params[:created_at].blank?
    	 date = params[:created_at].to_date
    	 @search.conditions.created_at_after = date.beginning_of_day()
    	 @search.conditions.created_at_before =  date.end_of_day()
   	end

   	unless params[:created_at_end].blank?
    	 date = params[:created_at_end].to_date
         @search.conditions.created_at_after = date.beginning_of_day()
    	 @search.conditions.created_at_before =  date.end_of_day()
   	end

    unless (params[:created_at_end].blank? ||  params[:created_at].blank?)
    	 start_date = "#{params[:created_at].to_date} "
    	 time = "00:00:00"
   	   end_date   =  Time.parse("#{params[:created_at_end].to_date} #{time}").advance(:days => 1)
    	 @search.conditions.created_at_after   = "#{start_date}#{time}"
    	 @search.conditions.and_created_at_before = "#{end_date}"
   	end


    @search.conditions.dealer.administrator_id = current_user.id unless super_admin?

    @qd_profiles = @search.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @qd_profiles }
      format.js  {  render :update do |page|
      	              page.replace_html 'qd_profile-list', :partial => 'qd_profiles_list'
     	            end
      	         }

     format.csv  {
                   csv_file = FasterCSV.generate do |csv|
                   #Headers
                   csv << [ 'Id','ListId','First Name','Middle Name' ,'Last Id','Suffix','Address','City','State',
                            'Zip','Zip4','Crrt','Dpc','Phone No' ,'Dealer Name','Tigger Detail Id','Addres2',
                            'level','auto17','pr01'
                          ]
                    #Data

                     if params[:type] == "all"
                       qd_profiles = QdProfile.find(:all)
                       qd_profiles.each do |prof|
                       csv << [ prof.id,prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address,
                               prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num,
                               prof.dealer.profile.name,prof.trigger_detail_id,prof.address2,prof.level,prof.auto17,
                               prof.pr01
                              ]
                       end
                    else
                    	@qd_profiles.each do |prof|
                      csv <<[ prof.id,prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address,
                               prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num,
                               prof.dealer.profile.name,prof.trigger_detail_id,prof.address2,prof.level,prof.auto17,
                               prof.pr01
                            ]
                      end
                 	  end


                 end
                 #sending the file to the browser
                 send_data(csv_file, :filename => 'qd_profile_list.csv', :type => 'text/csv', :disposition => 'attachment')
                }
    end
  end

  def assign_dealer
     @qd_profile = QdProfile.find(params[:id])
     if (!params[:dealer].blank? and !params[:dealer][:id].blank?)
    	@qd_profile.dealer_id = params[:dealer][:id]
        @qd_profile.save
        redirect_to admin_qd_profiles_url(:search => {:page =>params[:page],:per_page => params[:per_page]})
     else
  	@page = params[:page]
        @per_page = params[:per_page]
  	render :layout => false
     end
  end



private

   def super_admin?
    #logged_in? && current_user.has_role?('super_admin')
     logged_in? && (current_user.roles.map{|role| role.name}).include?('super_admin')
  end
  def check_role
 		if admin? and !session[:accept_terms]
    	 redirect_to(:controller =>"/sessions" ,:action =>:terms)
    end
	end

  def admin?
    logged_in? && current_user.has_role?(:admin)
  end

end

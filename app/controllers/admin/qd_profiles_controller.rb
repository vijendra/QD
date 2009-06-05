class Admin::QdProfilesController < ApplicationController
  require_role :admin
  layout 'admin'
  require 'fastercsv'

  def index

  	@search = QdProfile.new_search(params[:search])
  	@params = params[:search]
    @search.per_page ||= 15
   unless params[:today].blank?
       @search.conditions.created_at = Date.today
       params[:today] = nil
    end

    unless params[:created_at].blank?
    	 date = params[:created_at].to_date
         @search.conditions.created_at_after = date.beginning_of_day()
    	 @search.conditions.created_at_before =  date.end_of_day()
   	end
    unless params[:name].blank?
      group1 = @search.conditions.group
      group1.fname_like = params[:name]
      group1.or_lname_like = params[:name]
    end
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



end

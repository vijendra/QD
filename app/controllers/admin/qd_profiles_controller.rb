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

  def csv_print_file
     dealer = Dealer.find(params[:dealer_id])
     csv_file = FasterCSV.generate do |csv|
     print_file_headers = {}

     ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1', 'variable_data_2', 'variable_data_3','variable_data_4',
      'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].each do |identifier|

             ob = PrintFileField.by_dealer(dealer.id).by_identifier(identifier).first
	     if ob.blank?
		print_file_headers[identifier] = identifier
	     else
	        print_file_headers[ob.identifier] = ob.label
             end
	  end

     csv_headers = { 'name' => 'Dealer Name', 'first_name' => 'Dealer F Name', 'mid_name' => 'Dealer M Name',
                    'last_name' => 'Dealer L Name', 'phone_num' => 'Dealer Phone num', 'address' => 'Dealer Address' , 'city' => 'Dealer City', 'state' => 'Dealer State','postal_code' => 'Dealer Postal Code'}.merge(print_file_headers)

     fields_for_csv = dealer.csv_extra_field.fields rescue ['name', 'first_name','mid_name', 'last_name', 'phone_num', 'address', 'city', 'state', 'postal_code']
            #Headers
      csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_s] }

                  #Data
     qd_profiles = QdProfile.find(:all ,:conditions =>["dealer_id = ? and status = ? ",dealer.id ,"marked"])
     profile_array = field_values(fields_for_csv, dealer)
     qd_profiles.each do |prof|
     csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ] + profile_array
                      end
     end
     #sending the file to the browser
     send_data(csv_file, :filename => 'data_list.csv', :type => 'text/csv', :disposition => 'attachment')
 end

private

   def super_admin?
    #logged_in? && current_user.has_role?('super_admin')
     logged_in? && (current_user.roles.map{|role| role.name}).include?('super_admin')
  end
  def check_role
 		if admin? and !session[:accept_terms]
    	 redirect_to (:controller =>"/sessions" ,:action =>:terms)
    end
	end

	def field_values(field_list,dealer)
  	 print_file_field_idetifiers = ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1', 'variable_data_2',  'variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10']
  	 profile = dealer.profile
     field_list.map{|qd_field| if qd_field == "phone_num"
                                 "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}"
                              elsif print_file_field_idetifiers.include?(qd_field)
                                eval("PrintFileField.find_by_dealer_id_and_identifier(dealer.id,qd_field).value") rescue ' '
                              else
                                eval("profile.#{qd_field}") rescue eval("dealer.address.#{qd_field}")
                              end
                 }
   end

  def admin?
    logged_in? && current_user.has_role?(:admin)
  end

end

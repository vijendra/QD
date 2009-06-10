class QdProfilesController < ApplicationController
	before_filter :check_terms_conditions
  require 'fastercsv'

  def index
    #@qd_profiles = current_user.qd_profiles

    @search = QdProfile.new_search(params[:search])
    @search.conditions.dealer_id = current_user.id
    @search.per_page ||= 2
    @qd_profiles = @search.all
    @fields_to_be_shown = current_user.dealer_field.fields rescue []
    dealer = current_user.profile
    unless dealer.blank?
      flash[:notice] = "Order starting balance: #{dealer.starting_balance}, Current balance: #{dealer.current_balance} "
    end

    respond_to do |format|
                   format.html {}
                   format.js {  render :update do |page|
      	                           page.replace_html 'qd_profile-list', :partial => 'qd_profiles/qd_profiles_list'
     	                        end
      	                      }
                   format.csv {
                               csv_file = FasterCSV.generate do |csv|
                                  csv_headers = {:name => 'Dealer Name', :first_name => 'Dealer F Name', :last_name => 'Dealer L Name', :phone_num => 'Dealer Phone num', :address => 'Dealer Address', :city => 'Dealer City', :state => 'Dealer State', :postal_code => 'Dealer Postal Code'}

                                  fields_for_csv = current_user.csv_extra_field.fields rescue ['name', 'fname', 'lname', 'phone_num', 'address', 'city', 'state', 'postal_code']
                                  #Headers
                                  csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_sym] }

                                  #Data
                                  @qd_profiles.each do |prof|
                                     csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ] + field_values(fields_for_csv, prof)
                                  end
                                end
                                #sending the file to the browser
                                send_data(csv_file, :filename => 'data_list.csv', :type => 'text/csv', :disposition => 'attachment')
                               }
                             end
                 end



 private

  def field_values(field_list, prof)
    profile = prof.dealer.profile
    field_list.map{|qd_field| if qd_field == "phone_num"
                                 "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}"
                              else
                                eval("profile.#{qd_field}") rescue eval("prof.dealer.address.#{qd_field}")
                              end
                 }
   end


  def check_terms_conditions
       if !session[:accept_terms]
       	 redirect_to (:controller =>"sessions" ,:action =>:terms)
       end
 	end

end

class QdProfilesController < ApplicationController
  require 'fastercsv'

  def index
    #@qd_profiles = current_user.qd_profiles

    @search = QdProfile.new_search(params[:search])
    @search.conditions.dealer_id = current_user.id
    @search.per_page ||= 2
    @qd_profiles = @search.all
    @fields_to_be_shown = current_user.dealer_field.fields rescue []

    respond_to do |format|
                   format.html
                   format.js {  render :update do |page|
      	                           page.replace_html 'qd_profile-list', :partial => 'qd_profiles/qd_profiles_list'
     	                        end
      	                      }
                   format.csv {
                               csv_file = FasterCSV.generate do |csv|
                                  #Headers
                                  csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM']

                                  #Data
                                  @qd_profiles.each do |prof|
                                     csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ]
                                  end
                                end
                                #sending the file to the browser
                                send_data(csv_file, :filename => 'data_list.csv', :type => 'text/csv', :disposition => 'attachment')
                               }
                             end
                 end
end

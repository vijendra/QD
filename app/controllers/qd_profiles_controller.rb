class QdProfilesController < ApplicationController
  require 'fastercsv'

  def index
    @qd_profiles = current_user.qd_profiles
    @fields_to_be_shown = current_user.dealer_field.fields rescue []

    respond_to do |format|
                   format.html
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

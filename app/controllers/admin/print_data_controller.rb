class Admin::PrintDataController < ApplicationController
  layout 'admin'
  before_filter :check_login
  before_filter :find_dealer, :except =>[:csv_print_file]
  require 'fastercsv'


  def index
    respond_to do |format|
                   format.html {
                       @fields =  @dealer.csv_extra_field.blank?? Profile::CSV_EXTRA_FIELDS : @dealer.csv_extra_field.fields
                       Profile::PRINT_FILE_VARIABELS.map{|identifier| instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, identifier)) }
                       @marked_dates = @dealer.qd_profiles.find(:all,:conditions =>["status = ? ","marked"]).map { |prof| prof.marked_date }
                       @marked_dates.uniq!

                       @dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "template")
  		       if @dealer_template.nil?
     		         @dealer_template = PrintFileField.new(:dealer_id => @dealer.id, :identifier =>"template", :value =>"template1")
                         @dealer_template.save
                       end
                    }

                   format.csv {

                     search = QdProfile.new_search()
                     search.conditions.dealer.administrator_id = current_user.id unless current_user.has_role?('super_admin')
                     params[:m].blank? ? search.conditions.status = 'new' : search.conditions.status = 'marked'
                     search.per_page = 5000
                     search.group = 'trigger_detail_id'
                     search.select = 'trigger_detail_id'
                     triggers = search.all

                     #Construct CSV headers
                     qd_data_headers = QdProfile::QDPROFILE_CSV_HEADERS
                     dealer_profile_headers = []
                     Profile::CSV_GENERAL_FIELDS.map{ |key| dealer_profile_headers << Profile::CSV_HEADERS[key] }
                     variable_data_headers = Profile::PRINT_FILE_VARIABELS

                     csv_file = FasterCSV.generate do |csv|
                       #Construct CSV headers for variable fields
                       #Selected fields to be appended from dealers profile. if not found use general list.
                       #Exporting to CSV starts here.. Exporting headers
                       csv << qd_data_headers + ['Exported date'] + dealer_profile_headers + variable_data_headers

                       triggers.each do |tri|
                         trigger = tri.trigger_detail
                         dealer =  trigger.dealer
                         qd_profiles = params[:m].blank?? trigger.qd_profiles.to_be_unmark_printed : trigger.qd_profiles.to_be_printed
                         #Get and store dealer profile and variable data field values in an array
                         profile_values = Dealer.profile_field_values(Profile::CSV_GENERAL_FIELDS, dealer)
                         variable_values = PrintFileField.variable_field_values(Profile::PRINT_FILE_VARIABELS, dealer)

                        #Construct CSV row values for dealer profile related fields
                         dealer_profile_field_values = []
                         Profile::CSV_GENERAL_FIELDS.map {|key| dealer_profile_field_values << profile_values[key] }
                         dealer_profile_variable_values = Profile::PRINT_FILE_VARIABELS.map {|key| variable_values[key] }


                         #Exporting data rows
                         if dealer.profile.wants_data_printed
                           qd_profiles.each do |prof|

                             #To maintain orders as per the header we need to map again. Array is unorderd
                             csv << QdProfile::QDPROFILE_CSV_FIELDS.map{|p| eval("prof.#{p}")} + ["#{Time.now.strftime('%m-%d-%Y')}"] + dealer_profile_field_values + dealer_profile_variable_values

                             prof.print!
                           end

                           trigger.update_attribute('marked', 'printed')
                         end
                      end
                   end #End CSV Export
                   #sending the file to the browser
                   send_data(csv_file, :filename => "#{Time.now.strftime('%m-%d-%Y')}.csv", :type => 'text/csv', :disposition => 'attachment')
               }
      end
  end


 def csv_print_file
    unless params[:tid].blank?
      trigger = TriggerDetail.find(params[:tid])
      qd_profiles = trigger.qd_profiles
      dealer = trigger.dealer
    else
      qd_profiles = params[:profiles].map{|id|  QdProfile.find(id)}
      dealer = Dealer.find(params[:dealer][:id])
      trigger = qd_profiles.first.trigger_detail
    end

    #Dealer profile related fields, choosen to be exported, if not created yet use general list and dealer print file fields.
    dealer_profile_fields = dealer.csv_extra_field.fields rescue Profile::CSV_GENERAL_FIELDS

    #Construct CSV headers for other normal fields. For variable data fields get the label values
    variable_data_labels = PrintFileField.print_file_headers(dealer)
    qd_data_headers = QdProfile::QDPROFILE_CSV_HEADERS
    dealer_profile_headers = []
    dealer_profile_fields.map{ |key| dealer_profile_headers << Profile::CSV_HEADERS[key] unless Profile::PRINT_FILE_VARIABELS.include?(key)}
    variable_data_headers = Profile::PRINT_FILE_VARIABELS.map {|key| variable_data_labels[key]}

    #Get and store dealer profile and variable data field values in an array
    profile_values = Dealer.profile_field_values(dealer_profile_fields, dealer)
    variable_values = PrintFileField.variable_field_values(dealer_profile_fields, dealer)

    #Construct CSV row values for dealer profile related fields
    dealer_profile_field_values = []
    dealer_profile_fields.map {|key| dealer_profile_field_values << profile_values[key] unless Profile::PRINT_FILE_VARIABELS.include?(key)}
    dealer_profile_variable_values = Profile::PRINT_FILE_VARIABELS.map {|key| variable_values[key]}

    #export starts here
    csv_file = FasterCSV.generate do |csv|
      #Exporting headers
      csv <<  qd_data_headers + ['Exported date'] + dealer_profile_headers +  variable_data_headers

      #Exporting data rows
      qd_profiles.each do |prof|
        csv << QdProfile::QDPROFILE_CSV_FIELDS.map{|p| eval("prof.#{p}")} + ["#{Time.now.strftime('%m-%d-%Y')}"] + dealer_profile_field_values + dealer_profile_variable_values
        prof.print!
      end
    end #End CSV Export

    trigger.update_attribute('marked', 'printed')

    #sending the file to the browser
    send_data(csv_file, :filename => "#{trigger.created_at.strftime('%m-%d-%Y')}.csv", :type => 'text/csv', :disposition => 'attachment')
  end



  def admin_setting
    print_file_field = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,params[:identifier])
    print_file_field.update_attributes(:label =>params[:print_file_field][:label] ,:value =>params[:print_file_field][:value] )
    redirect_to( admin_dealer_print_data_path(:dealer_id => @dealer.id) )
  end

private

 def find_dealer
   @dealer = Dealer.find(params[:dealer_id]) unless params[:dealer_id].blank?
 end

 def profile_field_values(fields, dealer)
   profile = dealer.profile
   values = {}

   fields.map{|field| unless Profile::PRINT_FILE_VARIABELS.include?(field)
                        if field == "phone_num"
                          values[field] = "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}" rescue ''
                        else
                          #if not found in profile check in adrs.
                          values[field] = eval("profile.#{field}") rescue eval("dealer.address.#{field}")
                        end
                      end
                 }
   return values
 end

 def variable_field_values(field_list, dealer)
   values = {}
   field_list.map{|field| if Profile::PRINT_FILE_VARIABELS.include?(field)
                            values[field] = eval("PrintFileField.find_by_dealer_id_and_identifier(dealer.id, field).value") rescue ' '
                          end
                 }
   return values
 end


end


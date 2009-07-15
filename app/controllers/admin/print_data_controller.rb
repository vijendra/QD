class Admin::PrintDataController < ApplicationController
  layout 'admin'
  before_filter :find_dealer ,:except =>[:csv_print_file]
  require 'fastercsv'

  def index
    Profile::PRINT_FILE_VARIABELS.map{|identifier| instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, identifier)) }
    @marked_dates = @dealer.qd_profiles.find(:all,:conditions =>["status = ? ","marked"]).map { |prof| prof.marked_date }
    @marked_dates.uniq!

    @dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, "template")
    if @dealer_template.nil?
      @dealer_template = PrintFileField.new(:dealer_id =>@dealer.id,:identifier =>"template",:value =>"template1")
      @dealer_template.save
    end
    respond_to do |format|
                   format.html {}
                   format.csv {
                     search = QdProfile.new_search()
                     search.conditions.dealer.administrator_id = current_user.id unless super_admin?
                     search.conditions.status = 'marked'
                     search.group = 'trigger_detail_id'
                     search.select = 'trigger_detail_id'          
                     qd_profiles = search.all
                     
                     csv_file = FasterCSV.generate do |csv|
                     print_file_headers = {}
    
                     #Construct CSV headers for variable fields
    		     Profile::PRINT_FILE_VARIABELS.each do |identifier|
        	     ob = PrintFileField.by_dealer(dealer.id).by_identifier(identifier).first
	               if ob.blank?
	                 print_file_headers[identifier] = identifier
	               else
	                 print_file_headers[identifier] = ob.label.blank? ? identifier: ob.label 
                       end
                     end
     
       #Construct CSV headers for other normal fields. Make merge with above list
       csv_headers = Profile::CSV_HEADERS.merge(print_file_headers)

       #Selected fields to be appended from dealers profile. if not found use general list.
       fields_for_csv = dealer.csv_extra_field.fields rescue Profile::CSV_GENERAL_FIELDS

       profile_values = profile_field_values(fields_for_csv, dealer)
       variable_values = variable_field_values(fields_for_csv, dealer)

       #Exporting to CSV starts here.. Exporting headers
       csv << QdProfile.public_attributes.map{|field| field.humanize} + profile_values.keys.map{|field| csv_headers[field] } + variable_values.keys.map{|field| csv_headers[field] }

        #Exporting data rows
        qd_profiles.each do |prof|
          csv << QdProfile.public_attributes.map{|field| eval("prof.#{field}")} + profile_values.values + variable_values.values
          prof.print!
        end
    end #End CSV Export

                                                 
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

    csv_file = FasterCSV.generate do |csv|
      print_file_headers = {}
    
      #Construct CSV headers for variable fields
      Profile::PRINT_FILE_VARIABELS.each do |identifier|
        ob = PrintFileField.by_dealer(dealer.id).by_identifier(identifier).first
	if ob.blank?
	  print_file_headers[identifier] = identifier
	else
	  print_file_headers[identifier] = ob.label.blank? ? identifier: ob.label 
        end
      end
     
       #Construct CSV headers for other normal fields. Make merge with above list
       csv_headers = Profile::CSV_HEADERS.merge(print_file_headers)

       #Selected fields to be appended from dealers profile. if not found use general list.
       fields_for_csv = dealer.csv_extra_field.fields rescue Profile::CSV_GENERAL_FIELDS

       profile_values = profile_field_values(fields_for_csv, dealer)
       variable_values = variable_field_values(fields_for_csv, dealer)

       #Exporting to CSV starts here.. Exporting headers
       csv << QdProfile.public_attributes.map{|field| field.humanize} + profile_values.keys.map{|field| csv_headers[field] } + variable_values.keys.map{|field| csv_headers[field] }

        #Exporting data rows
        qd_profiles.each do |prof|
          csv << QdProfile.public_attributes.map{|field| eval("prof.#{field}")} + profile_values.values + variable_values.values
          prof.print!
        end
    end #End CSV Export


    #sending the file to the browser
    send_data(csv_file, :filename => "#{trigger.created_at.strftime('%m-%d-%Y')}.csv", :type => 'text/csv', :disposition => 'attachment')
  end

   def dispaly_admin_setting
     @print_file_field = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,params[:identifier])
     if @print_file_field.nil?
       @print_file_field = PrintFileField.new(:dealer_id => @dealer.id, :identifier => params[:identifier])
       @print_file_field.save
     end
     render :update do |page|
       page.replace_html 'text-body', :partial => 'admin/print_data/admin_settings'
     end
   end

  def admin_setting
     print_file_field = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,params[:identifier])
     print_file_field.update_attributes(:label =>params[:print_file_field][:label] ,:value =>params[:print_file_field][:value] )
     redirect_to( admin_dealer_print_data_path(:dealer_id => @dealer.id) )
  end



private

 def find_dealer
   @dealer = Dealer.find(params[:dealer_id])
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

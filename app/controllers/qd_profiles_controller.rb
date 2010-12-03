class QdProfilesController < ApplicationController
  before_filter :check_terms_conditions
  require 'fastercsv'
=begin
  def index
    #@qd_profiles = current_user.qd_profiles

    @search = QdProfile.new_search(params[:search])
    @search.conditions.dealer_id = current_user.id
    @search.per_page ||= 15
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
    @search.order_as ||= "DESC"
    @search.order_by ||= "created_at"
    @qd_profiles = @search.all
    @fields_to_be_shown = current_user.dealer_field.fields rescue []
    dealer = current_user.profile
    unless dealer.blank?
     @header_text = "Starting balance: #{dealer.starting_balance}, Current balance: #{dealer.current_balance} "
    end

    respond_to do |format|
                    format.html {}

                    format.js { render :update do |page|
      	                         page.replace_html 'qd_profile-list', :partial => 'qd_profiles/qd_profiles_list'
     	                         end }

                    format.csv {

                        csv_file = FasterCSV.generate do |csv|
                        print_file_headers = {}

                        ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1', 'variable_data_2',
                         'variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6',
                         'variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].each do |identifier|
		                      ob = PrintFileField.by_dealer(current_user.id).by_identifier(identifier).first
		                      if ob.blank?
		                        print_file_headers[identifier] = identifier
	                    	  else
	                  	    	print_file_headers[ob.identifier] = ob.label
                       		end
	              				end

			                  csv_headers = { 'name' => 'Dealer Name', 'first_name' => 'Dealer F Name', 'mid_name' => 'Dealer M Name','last_name' => 'Dealer L Name', 'phone_num' => 'Dealer Phone num', 'address' => 'Dealer Address', 'city' => 'Dealer City', 'state' => 'Dealer State', 'postal_code' => 'Dealer Postal Code'}.merge(print_file_headers)

      		              fields_for_csv = current_user.csv_extra_field.fields rescue ['name', 'first_name','mid_name', 'last_name', 'phone_num', 'address', 'city', 'state', 'postal_code']


                  #Headers
            			      csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_s] }
            			     qd_profiles = QdProfile.find(:all ,:conditions =>["dealer_id = ? and status = ? ",current_user.id ,"marked"])
                  #Data
                    profile_array = field_values(fields_for_csv, current_user)
                  qd_profiles.each do |prof|
                                     csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ] + profile_array
                                  end
                                end
                                #sending the file to the browser
                                send_data(csv_file, :filename => 'data_list.csv', :type => 'text/csv', :disposition => 'attachment')
                               }
        end
    end

=end

 def index
   @search = TriggerDetail.new_search(params[:search])
   unless params[:created_at].blank?
     date = params[:created_at].to_date
     @search.conditions.created_at_after = date.beginning_of_day()
     @search.conditions.created_at_before =  date.end_of_day()
   end
   @search.conditions.dealer_id = current_user.id
   @search.per_page ||= 15
   @search.order_as ||= "DESC"
   @search.order_by ||= "created_at"

   @triggers = @search.all
   @pending_append = current_user.pending_data_apppends.blank?
   
   @fields_to_be_shown = current_user.dealer_field.fields rescue []

   dealer = current_user.profile
   unless dealer.blank?
     @header_text = "Starting balance: #{dealer.starting_balance}, Current balance: #{dealer.current_balance} "
   end

   respond_to do |format|
                  format.html {}
                  format.js {
                               unless params[:tid].blank?
                                  @trigger = TriggerDetail.find(params[:tid])
                                  @qd_profiles = @trigger.qd_profiles
                                  render :update do |page|
      	                            page.replace_html 'trigger_qd_profile-list', :partial => 'qd_profiles/qd_profiles_list'
                                    page.visual_effect(:highlight, "trigger_qd_profile-list", :duration => 0.5)
     	                            end
    	                         else
    	                         	  render :update do |page|
      	                            page.replace_html 'qd_profile-list', :partial => 'qd_profiles/trigger_list'
     	                            end
   	                           end
  	                         }
   end
 end

 def mark_data
   unless params[:profiles].blank?
      params[:profiles].each do |id|
       qd_profile = QdProfile.find(id)
       qd_profile.update_attributes(:marked_date => Date.today, :dealer_marked => 'yes')
     end
     QdProfile.find(params[:profiles].first).trigger_detail.update_attribute('dealer_marked', 'yes')
   end
 
   unless params[:tid].blank?
     trigger = TriggerDetail.find(params[:tid])
     trigger.qd_profiles.map{|qp| qp.update_attribute('marked_date', Date.today)
                              qp.update_attribute('dealer_marked', 'yes')
                            }
     
     trigger.update_attribute('dealer_marked', 'yes')
   end

   flash[:notice] = "Data is successfully marked for printing."
   redirect_to(qd_profiles_path)
 end
 
 def unmark_data
   unless params[:tid].blank?
     trigger = TriggerDetail.find(params[:tid])
     trigger.qd_profiles.map{|qp| qp.update_attribute('marked_date', '')
                              qp.update_attribute('dealer_marked', 'no')
                            }
     
     trigger.update_attribute('dealer_marked', 'no')
   end

   flash[:notice] = "Data is successfully un-marked for printing."
   redirect_to(qd_profiles_path)
 end

 def print_file
   @profiles = current_user.qd_profiles.to_be_dealer_printed
   unless @profiles.blank?
     shell = params[:s]
     @shell_needed = !shell.blank? ? true : false #This will help to set background image
     @dealer_profile =  current_user.profile
     @dealer_address =  current_user.address
     @phone = "#{@dealer_profile.phone_1}-#{@dealer_profile.phone_2}-#{@dealer_profile.phone_3}"
     @auth_code =  @dealer_profile.auth_code rescue ' '
     @first_para = current_user.print_file_fields.find_by_identifier('text_body_1').value rescue 'Data Not entered. Conatcat your administrator'
     @sec_para = current_user.print_file_fields.find_by_identifier('text_body_2').value rescue 'Data Not entered. Conatcat your administrator'
     @third_para = current_user.print_file_fields.find_by_identifier('text_body_3').value rescue 'Data Not entered. Conatcat your administrator '
     template = current_user.print_file_fields.find_by_identifier('template')
     @w_site = current_user.print_file_fields.find_by_identifier('variable_data_1').value rescue 'www.autoappnow.com'
     @ask_for = current_user.print_file_fields.find_by_identifier('variable_data_2').value rescue ' '
     @ph_address = current_user.print_file_fields.find_by_identifier('variable_data_4').value rescue ' '
     @ph_city = current_user.print_file_fields.find_by_identifier('variable_data_5').value rescue ' '
     @ph_state_zip = current_user.print_file_fields.find_by_identifier('variable_data_6').value rescue ' '
     
     #if printing without shell then fetch the shell dimension set for the administrator
     if shell.blank?
       @positions = {}
       dimensions = current_user.administrator.shell_dimensions.all(:conditions => ["template = ?" , template.value])
       dimensions.map{ |rec| @positions[rec.variable]= rec.variable == 'bg_color'? rec.value : @positions[rec.variable]= rec.value.to_f } unless dimensions.blank?
     end
      
     #set template height and width
     unless template.blank?
       @print_template = "template#{template.value}"
       case @print_template
           when 'template1' then (file_name, size = 'Crediplex.pdf', @positions.blank? ? [611, 935] : [@positions['width'], @positions['height']]) 
           when 'template2' then (file_name, size = 'WSAC.pdf', @positions.blank? ? [612, 937] : [@positions['width'], @positions['height']])
           when 'template3' then (file_name, size = 'Letter_Master.pdf', @positions.blank? ? [612, 1008] : [@positions['width'], @positions['height']])
              else (file_name, size = 'print_file.pdf', [610, 1009])
        end

       options = { :left_margin => 0, :right_margin => 0, :top_margin => 0, :bottom_margin => 0, :page_size => size }
       prawnto :inline => false, :prawn => options, :page_orientation => :portrait, :filename => file_name
       render :layout => false
     else
       flash[:notice] = 'Print Shell is not yet selected. Please contact your administrator.'
       redirect_to(qd_profiles_path)
     end
   else
     flash[:notice] = 'No Data Marked for printing. Please make sure you have marked data for print.'
     redirect_to(qd_profiles_path)
   end
 end

  def print_labels
    @profiles = current_user.qd_profiles.to_be_dealer_printed
    unless @profiles.blank?
      options = { :left_margin => 0, :right_margin => 0, :top_margin => 0, :bottom_margin => 0, :page_size => [595, 770] }
      prawnto :inline => true, :prawn => options, :page_orientation => :portrait, :filename => 'labels.pdf'
      render :layout => false  
    else
      flash[:notice] = 'No Data Marked for printing. Please make sure you have marked data for print.'
      redirect_to(qd_profiles_path)
    end
 end


 def csv_print_file
   qd_profiles = current_user.qd_profiles.to_be_dealer_printed
   fields_to_be_shown = current_user.dealer_field.fields.sort rescue QdProfile.public_attributes
   
   #Construct CSV headers 
   dealer_profile_headers = [] 
   Profile::CSV_GENERAL_FIELDS.map{ |key| dealer_profile_headers << Profile::CSV_HEADERS[key] }
   variable_data_labels = PrintFileField.print_file_headers(current_user)
   variable_data_headers = Profile::PRINT_FILE_VARIABELS.map {|key| variable_data_labels[key]}
   fields_for_csv = current_user.csv_extra_field.fields rescue Profile::CSV_GENERAL_FIELDS
   #Get and store dealer profile and variable data field values in an array
   profile_values = Dealer.profile_field_values(fields_for_csv, current_user)
   variable_values = PrintFileField.variable_field_values(fields_for_csv, current_user)
                            
   #Construct CSV row values for dealer profile related fields  
    dealer_profile_field_values = []
    Profile::CSV_GENERAL_FIELDS.map {|key| dealer_profile_field_values << profile_values[key] } 
    dealer_profile_variable_values = Profile::PRINT_FILE_VARIABELS.map {|key| variable_values[key] }
    
    qd_profile_headers = []
    
    #only slected filed can shown
    QdProfile::FIELDS_TO_BE_SHOWN.map{ |key|
       qd_profile_headers <<  QdProfile::QDPROFILE_HEADERS["#{key}"]  if fields_to_be_shown.include?("#{key}")
    }
    
   
   csv_file = FasterCSV.generate do |csv|
      csv <<  qd_profile_headers + ['Exported date'] + dealer_profile_headers + variable_data_headers

      #Exporting data rows
      qd_profiles.each do |prof|
       
        qd_profile_values = []
        QdProfile::FIELDS_TO_BE_SHOWN.map{ |field|
          qd_profile_values <<  eval("prof.#{field}") if fields_to_be_shown.include?("#{field}")
         }
         
         csv << qd_profile_values + ["#{Time.now.strftime('%m-%d-%Y')}"] + dealer_profile_field_values + dealer_profile_variable_values
      end
    end #End CSV Export

    #sending the file to the browser
    send_data(csv_file, :filename => "#{Time.now.strftime('%m-%d-%Y')}.csv", :type => 'text/csv', :disposition => 'attachment')
 end

 private

 def profile_field_values(fields)
   profile = current_user.profile
   values = {}

   fields.map{|field| unless Profile::PRINT_FILE_VARIABELS.include?(field)
                        if field == "phone_num"
                          values[field] = "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}" rescue ''
                        else
                          #if not found in profile check in adrs.
                          values[field] = eval("profile.#{field}") rescue eval("current_user.address.#{field}")
                        end
                      end
                 }
   return values
 end
   
 def variable_field_values(field_list)
   values = {}
   field_list.map{|field| if Profile::PRINT_FILE_VARIABELS.include?(field)
                            values[field] = eval("PrintFileField.find_by_dealer_id_and_identifier(current_user.id, field).value") rescue ' '
                          end
                  }
   return values
 end

  def check_terms_conditions
     if !logged_in?
  		 redirect_to(login_url)
  	elsif !session[:accept_terms]
    	redirect_to(:controller =>"sessions" ,:action =>:terms)
    end
 	end

end

class Admin::PrintDataController < ApplicationController
	layout 'admin'
  before_filter :find_dealer ,:except =>[:csv_print_file]
  require 'fastercsv'

	def index
		  ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1','variable_data_2','variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].map{
     |identifier|  instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, identifier)) }

	  @marked_dates = @dealer.qd_profiles.find(:all,:conditions =>["status = ? ","marked"]).map { |prof| prof.marked_date }
  	@marked_dates.uniq!

  	@dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"template")
    if @dealer_template.nil?
    	@dealer_template = PrintFileField.new(:dealer_id =>@dealer.id,:identifier =>"template",:value =>"template1")
    	@dealer_template.save
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
      ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1', 'variable_data_2',
        'variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6',
        'variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10'].each do |identifier|
           ob = PrintFileField.by_dealer(dealer.id).by_identifier(identifier).first
	   if ob.blank?
	     print_file_headers[identifier] = identifier
	   else
	     print_file_headers[ob.identifier] = ob.label
           end
       end
     
       #Construct CSV headers for other normal fields. Make merge with above list
       csv_headers = {'name' => 'Dealer Name', 'first_name' => 'Dealer F Name', 'mid_name' => 'Dealer M Name','last_name' => 'Dealer L Name', 'phone_num' => 'Dealer Phone num', 'address' => 'Dealer Address', 'city' => 'Dealer City', 'state' => 'Dealer State', 'postal_code' => 'Dealer Postal Code'}.merge(print_file_headers)

       #Selected fields to be appended from dealers profile. if not found use general list.
       fields_for_csv = dealer.csv_extra_field.fields rescue ['name', 'first_name', 'last_name', 'phone_num', 'address', 'city', 'state','postal_code']

       profile_array = field_values(fields_for_csv, dealer)

       if dealer.profile.data_sources == "seekerinc"
         #Exporting to CSV starts here.. Exporting headers
         csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_s] }

          #Exporting data rows
          qd_profiles.each do |prof|
            csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ] + profile_array
            prof.print!
          end
        else
          csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM', 'ADDRESS 2', ' LEVEL', 'AUTO17', 'PR01' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_s] }
          qd_profiles.each do |prof|
            csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ,prof.address2,prof.level, prof.auto17, prof.pr01] + profile_array
            prof.print!
         end
       end #End data source check
     end #End CSV Export

     #sending the file to the browser
     send_data(csv_file, :filename => "#{trigger.created_at.strftime('%m-%d-%Y')}.csv", :type => 'text/csv', :disposition => 'attachment')
   end

   def dispaly_admin_setting
     @print_file_field = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,params[:identifier])
     if @print_file_field.nil?
       @print_file_field = PrintFileField.new(:dealer_id => @dealer.id,:identifier => params[:identifier])
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

    def field_values(field_list, dealer)
      print_file_field_idetifiers = ['text_body_1', 'text_body_2', 'text_body_3','variable_data_1', 'variable_data_2', 'variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10']

      profile = dealer.profile

      field_list.map{|qd_field| if qd_field == "phone_num"
                                 "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}"
                              elsif print_file_field_idetifiers.include?(qd_field)
                                eval("PrintFileField.find_by_dealer_id_and_identifier(dealer.id,qd_field).value") rescue ' '
                              else
                                eval("profile.#{qd_field}") rescue eval("dealer.address.#{qd_field}") #if not found in profile check in adrs.
                              end
                 }
   end


end

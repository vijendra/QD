class Admin::PrintDataController < ApplicationController
	layout 'admin'
  before_filter :find_dealer ,:except =>[:mark_data_for_printed]
  require 'fastercsv'

	def index
		  ['text_body_1', 'text_body_2', 'text_body_3', 'variable_data_4', 'variable_data_5', 'variable_data_6',
     'variable_data_7', 'variable_data_8', 'variable_data_9'].map{
     |identifier|  instance_variable_set( "@#{identifier}", PrintFileField.find_by_dealer_id_and_identifier(@dealer.id, identifier)) }

		@marked_dates = @dealer.qd_profiles.find(:all,:conditions =>["status = ? ","marked"]).map { |prof| prof.marked_date }
  	@marked_dates.uniq!
  	@dealer_template = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"template")
    if @dealer_template.nil?
    	@dealer_template = PrintFileField.new(:dealer_id =>@dealer.id,:identifier =>"template",:value =>"template1")
    	@dealer_template.save
    end

	end

	def mark_data_for_printed
 		 dealer = Dealer.find(params[:dealer][:id])
     csv_file = FasterCSV.generate do |csv|
     csv_headers = { :name => 'Dealer Name', :first_name => 'Dealer F Name', :mid_name => 'Dealer M Name',
                     :last_name => 'Dealer L Name', :phone_num => 'Dealer Phone num',:address => 'Dealer Address',
                     :city => 'Dealer City', :state => 'Dealer State',:postal_code => 'Dealer Postal Code',
                     :text_body_1 =>' Dealer Text Boby 1',:text_body_2 => ' Dealer Text Boby 2',
                     :text_body_3 =>' Dealer Text Boby 3',:variable_data_4 => 'Variable Data 4',
                     :variable_data_5 => 'Variable Data 5',:variable_data_6 => 'Variable Data 6',
                     :variable_data_7 => 'Variable Data 7',:variable_data_8 => 'Variable Data 8',
                     :variable_data_9 => 'Variable Data 9'
                    }

     fields_for_csv = dealer.csv_extra_field.fields rescue ['name', 'first_name', 'last_name', 'phone_num', 'address', 'city', 'state','postal_code']

		   if dealer.profile.data_sources == "seekerinc"
  		   	csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_sym] }
        params[:profiles].each do |id|
        	 prof = QdProfile.find(id)
        	csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ] + field_values(fields_for_csv, prof)
        	 prof.print!
                         end
       else

       	 	csv << ['LIST ID', 'F NAME', 'M NAME', 'L NAME', 'SUFFIX', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 'ZIP4', 'CRRT', 'DPC', 'PHONE_NUM' ,'ADDRESS 2' ,' LEVEL' ,'AUTO17' ,'PR01' ] + fields_for_csv.map{|qd_field| csv_headers[qd_field.to_sym] }
       	 	params[:profiles].each do |id|
        	 prof = QdProfile.find(id)
          csv << [prof.listid, prof.fname, prof.mname, prof.lname, prof.suffix, prof.address, prof.city, prof.state, prof.zip, prof.zip4, prof.crrt, prof.dpc, prof.phone_num ,prof.address2,prof.level,prof.auto17,prof.pr01] + field_values(fields_for_csv, prof)

        	 prof.print!

                         end
       end

     end
     #sending the file to the browser
     send_data(csv_file, :filename => 'data_list.csv', :type => 'text/csv', :disposition => 'attachment')

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
    redirect_to ( admin_dealer_print_data_path(:dealer_id => @dealer.id) )
  end


	private

    def find_dealer
    	@dealer = Dealer.find(params[:dealer_id])
    end

    def field_values(field_list, prof)
    	 print_file_field_idetifiers = ['text_body_1','text_body_2','text_body_3','variable_data_4','variable_data_5',
		                               'variable_data_6','variable_data_7','variable_data_8','variable_data_9']
      profile = prof.dealer.profile
      field_list.map{|qd_field| if qd_field == "phone_num"
                                  "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}"
                                elsif print_file_field_idetifiers.include?(qd_field)
                                 eval("PrintFileField.find_by_dealer_id_and_identifier(prof.dealer_id,qd_field).value") rescue ''
                                else
                                   eval("profile.#{qd_field}") rescue eval("prof.dealer.address.#{qd_field}")
                                end


                     }
   end


end

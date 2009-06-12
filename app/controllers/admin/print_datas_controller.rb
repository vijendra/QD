class Admin::PrintDatasController < ApplicationController
  before_filter :find_dealer ,:except =>[:mark_data_for_printed]

	def index
		@variable_data_4 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_4")
		@variable_data_5 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_5")
		@variable_data_6 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_6")
		@variable_data_7 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_7")
		@variable_data_8 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_8")
		@variable_data_9 = PrintFileField.find_by_dealer_id_and_identifier(@dealer.id,"variable_data_9")
		@marked_dates = @dealer.qd_profiles.find(:all,:conditions =>["status = ? ","marked"]).map { |prof| prof.marked_date }
		@marked_dates.uniq!
	end

	def mark_data_for_printed
 		 dealer = Dealer.find(params[:dealer][:id])

     csv_file = FasterCSV.generate do |csv|
     csv_headers = { :name => 'Dealer Name', :first_name => 'Dealer F Name', :mid_name => 'Dealer M Name',
                     :last_name => 'Dealer L Name', :phone_num => 'Dealer Phone num',:text_body_1 =>' Dealer Text Boby 1',
                     :text_body_2 =>' Dealer Text Boby 2',:text_body_3 =>' Dealer Text Boby 3',
                     :variable_data_4 => 'Variable Data 4',:variable_data_5 => 'Variable Data 5',
                     :variable_data_6 => 'Variable Data 6',:variable_data_7 => 'Variable Data 7',
                     :variable_data_8 => 'Variable Data 8',:variable_data_9 => 'Variable Data 9',
                     :address => 'Dealer Address',:city => 'Dealer City', :state => 'Dealer State',
                     :postal_code => 'Dealer Postal Code'
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

	private
    def find_dealer
    	@dealer = Dealer.find(params[:dealer_id])
    end
     def field_values(field_list, prof)
    profile = prof.dealer.profile
    field_list.map{|qd_field| if qd_field == "phone_num"
                                 "#{profile.phone_1}-#{profile.phone_2}-#{profile.phone_3}"
                              else
                                eval("profile.#{qd_field}") rescue eval("prof.dealer.address.#{qd_field}")
                              end
                 }
   end
end

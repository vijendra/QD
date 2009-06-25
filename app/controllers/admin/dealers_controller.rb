class Admin::DealersController < ApplicationController
  require_role :admin

  layout 'admin'
  require 'fastercsv'
  before_filter :check_role

  def index
    @search = Dealer.new_search(params[:search])
    @params = params[:search]
    @search.page ||=1
    @search.per_page ||=10

    @search.conditions.administrator_id = current_user.id unless super_admin?
    @dealers = @search.all

   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dealer }
      format.js {  render :update do |page|
      	            page.replace_html 'dealer-list', :partial => 'dealers_list'
     	            end
      	        }
      format.csv  {
                    csv_file = FasterCSV.generate do |csv|
                   #Headers
                   csv << [ 'Id','Login','Email','Profile Name','Auth Code','Emails xml','Emails Html','Emails Extra',
                            'First Name','Middle Name','Last Name','Phone Number','Data Source',' marketer_net_po',
                            'wants_data_printed', 'comments','Stating Balance','Current Balance','Rate','Address','Address2',
                            'City','State','Zip'
                          ]
                    #Data
                    if params[:type] == "all"

                     Dealer.all.each do |d|
                     csv << [ d.id,d.login,d.email,d.profile.name,d.profile.auth_code,d.profile.emails_xml,d.profile.emails_html,
                              d.profile.emails_extra,d.profile.first_name,d.profile.mid_name, d.profile.last_name ,
                              "#{d.profile.phone_1}-#{d.profile.phone_2}-#{d.profile.phone_3}",
                              d.profile.data_sources ,d.profile.marketer_net_po,d.profile.wants_data_printed,d.profile.comments,
                              d.profile.starting_balance,d.profile.current_balance,d.profile.rate, d.address.address,
                              d.address.address2,d.address.city, d.address.state,d.address.postal_code
                            ]
                     end
                   else
                   	 @dealers.each do |d|
                     csv << [ d.id,d.login,d.email,d.profile.name,d.profile.auth_code,d.profile.emails_xml,d.profile.emails_html,
                              d.profile.emails_extra,d.profile.first_name,d.profile.mid_name, d.profile.last_name ,
                              "#{d.profile.phone_1}-#{d.profile.phone_2}-#{d.profile.phone_3}",
                              d.profile.data_sources,d.profile.marketer_net_po,d.profile.wants_data_printed,d.profile.comments,
                              d.profile.starting_balance,d.profile.current_balance,d.profile.rate,
                              d.address.address,d.address.address2,d.address.city, d.address.state,d.address.postal_code
                            ]
                     end
                    end

                 end
                 #sending the file to the browser
                 send_data(csv_file, :filename => 'dealers_list.csv', :type => 'text/csv', :disposition => 'attachment')
                }
    end
  end

  def show
    @dealer = Dealer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dealer }
    end
  end


  def new
    @dealer = Dealer.new
    @dealer.build_profile
    @dealer.build_address
    respond_to do |format|
      format.html
      format.xml  { render :xml => @dealer }
    end
  end

  def edit
    @dealer = Dealer.find(params[:id])

  end

  def create
    @dealer = Dealer.new(params[:dealer])

    respond_to do |format|
      if @dealer.save
        @dealer.register!
        @dealer.activate!
        flash[:notice] = 'Dealer was successfully created.'
        format.html { redirect_to(admin_dealers_path)}
        format.xml  { render :xml => @dealer, :status => :created, :location => @dealer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dealer.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @dealer = Dealer.find(params[:id])
    respond_to do |format|
      if @dealer.update_attributes(params[:dealer])
        flash[:notice] = 'Dealer was successfully updated.'
        format.html { redirect_to(admin_dealers_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dealer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @dealer = Dealer.find(params[:id])
    @dealer.profile.destroy
    @dealer.address.destroy
    @dealer.destroy

    respond_to do |format|
      format.html { redirect_to(admin_dealers_url) }
      format.xml  { head :ok }
    end
  end

  def csv
    @dealer = Dealer.find(params[:id])
    render :lauout =>"false"
  end



  def csv_import
    @dealer = Dealer.find(params[:dealer_id])
    @balance = @dealer.profile.current_balance
    no_of_records = 0
    unless (params[:dealer][:order_number].blank? or params[:dealer][:file].blank?)
     if params[:type] == "seekerinc"
    	trigger = TriggerDetail.create( :dealer_id => @dealer.id, :data_source => 'seekerinc' ,
    	                                :total_records => no_of_records, :order_number => params[:dealer][:order_number] ,
    	                                :balance => @balance )
      data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(params[:dealer][:file].path, :headers => :false) do |row|
      @balance = @balance - 1
      no_of_records = no_of_records + 1
      data_set = {:dealer_id =>  @dealer.id, :trigger_detail_id => trigger.id}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end
    trigger.update_attribute('total_records', no_of_records)
    trigger.update_attribute('balance', @balance)
   else
      trigger = TriggerDetail.create(:dealer_id => @dealer.id, :data_source => 'marketernet', :total_records => no_of_records, :order_number => params[:dealer][:order_number], :balance => @balance )
       field_list = ['lname', 'fname', 'mname', 'address', 'address2', 'city', 'state', 'zip',  'zip4', 'level', '', 'auto17', 'crrt', 'dpc', 'phone_num', 'pr01']
      FasterCSV.foreach(params[:dealer][:file].path, :headers => :false) do |row|
         no_of_records = no_of_records + 1
         @balance = @balance -1
       	 data_set = {:dealer_id => @dealer.id, :trigger_detail_id => trigger.id, :listid => "#{params[:dealer][:order_number]}_#{row[10]}" }
         field_list.map {|f| data_set[f] = row[field_list.index(f)] unless f.blank?}
         QdProfile.create(data_set)
        end
      trigger.update_attribute('total_records', no_of_records)
      trigger.update_attribute('balance', @balance)
    end
     dealer.profile.update_attribute('current_balance', @balance)
     flash[:notice] = 'CSV data is successfully imported.'
     redirect_to(admin_dealers_url)
   else
   	  flash[:notice] ="Please Enter Order No and select a File"
  	  redirect_to(admin_dealers_url)
  	end

  end


   def reset_password
    @dealer = Dealer.find(params[:id])
    @dealer.reset_password!
    flash[:notice] = "A new password has been sent to the Dealer by email."
    redirect_to edit_admin_dealer_path(@dealer)
  end

 def inactive
 	  @dealer = Dealer.find(params[:id])
    @dealer.deactivate!
    redirect_to admin_dealers_path(:search => {:page =>params[:page],:per_page => params[:per_page]} )
  end

  def active
    @dealer = Dealer.find(params[:id])
    @dealer.active!
    redirect_to admin_dealers_path(:search => {:page =>params[:page],:per_page => params[:per_page]})
  end

  def assign_administrator
    @dealer = Dealer.find(params[:id])

    unless (params[:administrator].blank? || params[:administrator][:id].blank?)
      @dealer.update_attributes(:administrator_id => params[:administrator][:id])

      redirect_to admin_dealers_url(:search => {:page =>params[:page],:per_page => params[:per_page]})
  	else
  		@page = params[:page]
      @per_page = params[:per_page]
  	  render :layout => false
   	end
 	end

  def import_dealer_csv
    unless ( params[:dealer].blank? ||params[:dealer][:file].blank?)
      import_file = params[:dealer][:file]
      FasterCSV.parse(import_file.read).each do |row|
  	login = "dealer#{row[0]}"
        dealer = Dealer.new(:login => "#{login}" , :email => (row[2].blank? ? "dummy#{row[0]}@email.com" : row[2]), :password => 'password', :password_confirmation => 'password')
        if dealer.save
            if row[11].blank?
    	        phone =[nil, nil, nil]
   	        else
    	        phone = row[11].split("-")
   	        end

          unless dealer.blank?
    	    Profile.create( :user_id => dealer.id, :name => row[3], :auth_code => row[4],:emails_xml => row[5],
    	    	            :emails_html => row[6],:emails_extra => row[7],:first_name => row[8],:mid_name => row[9],
    	    	            :last_name => row[10],:phone_1 => phone[0], :phone_2 => phone[1],:phone_3 => phone[2],
    	    	            :data_sources => row[12],:marketer_net_po => row[13],:wants_data_printed => row[14],
    	    	            :comments => row[15],:starting_balance => row[16],:current_balance => row[17],:rate => [18]
    	    	          )
    	   Address.create( :user_id => dealer.id ,:address => row[28],:address2 => row[29],:city => row[30] ,
    	    	            :state => row[31], :postal_code => row[32]
    	    	           )
    	    	dealer.register!
    	    	dealer.activate!
          end
       end
      end
      ['135', '136' , '152', '158'	,'220' , '221'].each do |id|
         dealer = Dealer.find(id)
         dealer.profile.destroy
         dealer.address.destroy
         dealer.destroy
      end

      redirect_to admin_dealers_path
     else
       render :layout => false
     end
   end

 	def authentication_code
 		@dealer = Dealer.find(params[:id])
 		unless params[:auth_code].blank?
		  @dealer.profile.update_attributes(:auth_code => params[:auth_code])
		  redirect_to admin_dealers_path
	 else
 		render :layout => false
		end
	end


 	private

 	def check_role
 		if admin? and !session[:accept_terms]
    	redirect_to(:controller =>"/sessions" ,:action =>:terms)
    end
	end

  def admin?
    logged_in? && current_user.has_role?(:admin)
  end

  def super_admin?

     logged_in? && (current_user.roles.map{|role| role.name}).include?('super_admin')
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

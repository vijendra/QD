class Admin::DealersController < ApplicationController
  require_role :admin
  layout 'admin'
  require 'fastercsv'

  def index
    @search = Dealer.new_search(params[:search])
    @params = params[:search]
    @search.page ||=1
    @search.per_page ||=10
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
                            'wants_data_printed', 'comments','Stating Balance','Current Balance','Rate','Text Body 1','Text Body 2','Text Body 3', 'Variable Data 4','Variable Data 5','Variable Data 6',
                            'Variable Data 7','Variable Data 8','Variable Data 9','Address','Address2', 'City','State','Zip'
                          ]
                    #Data
                    if params[:type] == "all"
                     dealers = Dealer.find(:all)
                     dealers.each do |d|
                     csv << [ d.id,d.login,d.email,d.profile.name,d.profile.auth_code,d.profile.emails_xml,d.profile.emails_html,
                              d.profile.emails_extra,d.profile.first_name,d.profile.mid_name, d.profile.last_name ,
                              "#{d.profile.phone_1}-#{d.profile.phone_2}-#{d.profile.phone_3}",
                              d.profile.data_sources,d.profile.marketer_net_po,d.profile.wants_data_printed,d.profile.comments,
                              d.profile.starting_balance,d.profile.current_balance,d.profile.rate,d.profile.text_body_1,
                              d.profile.text_body_2, d.profile.text_body_3,d.profile.variable_data_4,d.profile.variable_data_5,
                              d.profile.variable_data_6,d.profile.variable_data_7,d.profile.variable_data_8,
                              d.profile.variable_data_9, d.address.address,d.address.address2,d.address.city, d.address.state,
                              d.address.postal_code
                            ]
                     end
                   else
                   	 @dealers.each do |d|
                     csv << [ d.id,d.login,d.email,d.profile.name,d.profile.auth_code,d.profile.emails_xml,d.profile.emails_html,
                              d.profile.emails_extra,d.profile.first_name,d.profile.mid_name, d.profile.last_name ,
                              "#{d.profile.phone_1}-#{d.profile.phone_2}-#{d.profile.phone_3}",
                              d.profile.data_sources,d.profile.marketer_net_po,d.profile.wants_data_printed,d.profile.comments,
                              d.profile.starting_balance,d.profile.current_balance,d.profile.rate,d.profile.text_body_1,
                              d.profile.text_body_2, d.profile.text_body_3,d.profile.variable_data_4,d.profile.variable_data_5,
                              d.profile.variable_data_6,d.profile.variable_data_7,d.profile.variable_data_8,
                              d.profile.variable_data_9, d.address.address,d.address.address2,d.address.city, d.address.state,
                              d.address.postal_code
                            ]
                     end
                    end

                 end
                 #sending the file to the browser
                 send_data(csv_file, :filename => 'dealers_list.csv', :type => 'text/csv', :disposition => 'attachment')
                }
    end
  end

  # GET /dealers/1
  # GET /dealers/1.xml
  def show
    @dealer = Dealer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dealer }
    end
  end

  # GET /dealers/new
  # GET /dealers/new.xml
  def new
    @dealer = Dealer.new
    @dealer.build_profile
    @dealer.build_address
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dealer }
    end
  end

  # GET /dealers/1/edit
  def edit
    @dealer = Dealer.find(params[:id])

  end

  # POST /dealers
  # POST /dealers.xml
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

  # DELETE /dealers/1
  # DELETE /dealers/1.xml
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
    dealer = Dealer.find(params[:dealer_id])
    balance = dealer.profile.current_balance

    data_source1 = ['listid', 'fname', 'mname', 'lname', 'suffix', 'address', 'city', 'state', 'zip',  'zip4', 'crrt', 'dpc', 'phone_num']
    FasterCSV.foreach(params[:dealer][:file].path, :headers => :false) do |row|
      balance = balance -1
      data_set = {:dealer_id => params[:dealer_id]}
      data_source1.map {|f| data_set[f] = row[data_source1.index(f)] }
      QdProfile.create(data_set)
    end

    dealer.profile.update_attribute('current_balance', balance)
    flash[:notice] = 'CSV data is successfully imported.'

    redirect_to(admin_dealers_url)
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
  #	page = params[:page]
 	#  per_page = params[:per_page]
    @dealer = Dealer.find(params[:id])
    @dealer.active!
    redirect_to admin_dealers_path(:search => {:page =>params[:page],:per_page => params[:per_page]})
  end


  def assign_administrator
    @dealer = Dealer.find(params[:id])

    unless (params[:administrator].blank? || params[:administrator][:id].blank?)
      profile = @dealer.profile
      profile.administrator_id = params[:administrator][:id]
      profile.save
      redirect_to admin_dealers_url(:search => {:page =>params[:page],:per_page => params[:per_page]})
  	else
  		@page = params[:page]
      @per_page = params[:per_page]
  	  render :layout => false
   	end
 	end

  def import_dealer_csv

  	unless ( params[:dealer].blank? ||params[:dealer][:file].blank?)
  		email_list = []
  		import_file = params[:dealer][:file]
  		 FasterCSV.parse(import_file.read).each do |row|
  		     unless row[2]=="Email"
  		     if row[2].blank?
  		      	email = row[7].split(";").first
   		      	if email_list.include?(email)
   		      		email = row[7].split(";").last
  		      	end
  		      	email_list << email
 		       else
 		      	 email = row[2]
 		      	 email_list << email
		      	end

            login = "dealer#{row[0]}"
            	puts "ppppppppppppppppppppppppppppppppp#{email}#{ login}"
    	    dealer = Dealer.new(:dealer_id => row[0].to_i,:login => "#{login}" ,:email => "#{email}" ,:password =>'password',:password_confirmation =>'password')

    	    if dealer.save

    	      if row[11].blank?
    	      	phone =[nil,nil,nil]
   	        else
    	        phone = row[11].split("-")
   	        end
    	    	Profile.create( :user_id => dealer.id, :name=> row[3],:auth_code=>row[4],:emails_xml=>row[5],
    	    	                :emails_html=>row[6],:emails_extra=>row[7],:first_name=>row[8],:mid_name=>row[9],
    	    	                :last_name=>row[10],:phone_1=>phone[0], :phone_2=>phone[1],:phone_3=> phone[2],
    	    	                :data_sources=>row[12],:marketer_net_po=> row[13],:wants_data_printed=>row[14],
    	    	                :comments=>row[15],:starting_balance=>row[16],:current_balance=>row[17],:rate =>[18],
    	    	                :text_body_1=>row[19],:text_body_2 => row[20], :text_body_3 => row[21] ,
    	    	                :variable_data_4 => row[22] ,:variable_data_5 => row[23] ,:variable_data_6 => row[24],
    	    	                :variable_data_7 => row[25] ,:variable_data_8 => row[26] ,:variable_data_9 => row[27]
    	    	              )
    	    	Address.create( :user_id => dealer.id ,:address =>row[28],:address2 =>row[29],:city =>row[30] ,
    	    	                :state =>row[31],:postal_code =>row[32]
    	    	              )
    	    	dealer.register!
    	    	dealer.activate!
  	      else
   	      end
        end
       end

       redirect_to admin_dealers_path
 	  else
  	  render :layout => "false"
 	  end
 	end




end

# See how all your routes lay out with "rake routes"
ActionController::Routing::Routes.draw do |map|
  map.resources :data_appends

  map.resources :dealers, :has_one =>[:print_file_field ,:csv_extra_field]

  # RESTful rewrites

  map.signup   '/signup',   :controller => 'users',    :action => 'new'
  map.register '/register', :controller => 'users',    :action => 'create'
  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy', :conditions => {:method => :delete}

  map.user_troubleshooting '/users/troubleshooting', :controller => 'users', :action => 'troubleshooting'
  map.user_forgot_password '/users/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.user_reset_password  '/users/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password'
  map.user_forgot_login    '/users/forgot_login',    :controller => 'users', :action => 'forgot_login'
  map.user_clueless        '/users/clueless',        :controller => 'users', :action => 'clueless'

  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }

  map.resources :users, :member => { :edit_password => :get,
                                     :update_password => :put,
                                     :edit_email => :get,
                                     :update_email => :put,
                                     :edit_avatar => :get,
                                     :update_avatar => :put }

  map.resource :session, :member => { :accept_terms => :post}

  # Profiles
  map.resources :profiles ,:collection => { :reset_password => :get }
  map.resources :qd_profiles, :collection =>{:mark_data => :post, :unmark_data => :post, :print_file => :get, :print_labels => :get, :csv_print_file => :get}

  # Administration
  map.namespace(:admin) do |admin|
    admin.root :controller => 'dashboard', :action => 'index'
    admin.resources :settings

    admin.resources :dealers, :has_one =>[:dealer_field] ,:member => {:activate => :post, :inactive => :post, :test_print => :get, :reset_password => :put, :csv => :get, :assign_administrator =>:get, :authentication_code => :get, :export_dnc => :get }, :collection => {:import_dealer_csv => :get }, :has_many => [:dealer_accounts, :print_data]
    admin.resources :dealers do |dealer|
      #dealer.resource :print_data, :controller => 'print_data'
       dealer.resources :shell_dimensions
    end
    admin.resources :qd_profiles, :member => {:assign_dealer => :get }, :collection =>{:mark_data => :post, :unmark_data => :post, :accurate_append => :post}
    admin.resources :trigger_details, :collection => { :process_triggers => :get}, :member => {:mark_processed => :any }
    admin.resources :data_appends, :collection => {:ncoa_append => :get} do |append|
      append.resources :appended_qd_profiles
    end

    admin.resources :dnc_numbers
    admin.resources :print_file_fields
    #admin.resources :
    admin.resource :robot, :member => {:run => :get, :active_dealer_email => :get,  :inactive_dealer_email => :get}

    admin.resources :administrators ,:has_one =>[:administrator_profile] ,:member => { :suspend   => :put,
                                         :unsuspend => :put,
                                         :activate  => :put,
                                         :purge     => :delete,
                                         :reset_password => :put },
                            :collection => { :pending   => :get,
                                             :active    => :get,
                                             :suspended => :get,
                                             :deleted   => :get }
    admin.resources :users, :member => { :suspend   => :put,
                                         :unsuspend => :put,
                                         :activate  => :put,
                                         :purge     => :delete,
                                         :reset_password => :put ,
                                         :user_image => :post

                                         },
                            :collection => { :pending   => :get,
                                             :active    => :get,
                                             :suspended => :get,
                                             :deleted   => :get,:admin_setting =>:post }
  end

  map.print_file 'admin/print_data/print_file.csv',   :controller => 'admin/print_data',  :action => 'index', :format => 'csv'
  map.shell_matrix 'admin/print_data/shell_matrix.pdf', :controller => 'admin/shell_dimensions',  :action => 'shell_matrix', :format => 'pdf'
  map.shell_matrix_html 'admin/dealers/print_data/shell_matrix', :controller => 'admin/shell_dimensions',  :action => 'shell_matrix'
  #map.shell_dimension 'admin/print_data/print_shell_dimension', :controller => 'admin/print_data',  :action => 'print_shell_dimension'
  # Dashboard as the default location
  map.root :controller => 'sites', :action => 'index'
  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end


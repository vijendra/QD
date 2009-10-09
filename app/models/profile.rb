# TODO: Specify profile fields in db/migrate/002_create_profiles.rb
# TODO: (base_app) Add avatar/photo upload
class Profile < ActiveRecord::Base
  # These fields in a profile are private, and will not be shown to other users.
  PRIVATE_FIELDS = ["id", "created_at", "updated_at", "user_id"]
  PRINT_FILE_VARIABELS = ['variable_data_1', 'variable_data_2', 'variable_data_3','variable_data_4', 'variable_data_5', 'variable_data_6','variable_data_7', 'variable_data_8', 'variable_data_9','variable_data_10','text_body_1', 'text_body_2', 'text_body_3']

  CSV_HEADERS = {'name' => 'Dealer Name','display_name' => 'Profile Display Name', 'first_name' => 'Dealer F Name', 'mid_name' => 'Dealer M Name','last_name' => 'Dealer L Name', 'phone_num' => 'Dealer Phone num', 'address' => 'Dealer Address', 'city' => 'Dealer City', 'state' => 'Dealer State', 'postal_code' => 'Dealer Postal Code', 'auth_code' => 'Dealer Authorization code'}

  CSV_GENERAL_FIELDS = ['name','display_name','auth_code','first_name','mid_name', 'last_name', 'phone_num', 'address', 'city', 'state','postal_code']
  # TODO: Add validations, if you require any for the profile fields
  CSV_EXTRA_FIELDS = ['name','display_name','auth_code','emails_extra','first_name','mid_name','last_name','phone_num','address','city','state','postal_code','text_body_1','text_body_2','text_body_3','variable_data_1','variable_data_2','variable_data_3','variable_data_4','variable_data_5','variable_data_6','variable_data_7','variable_data_8','variable_data_9','variable_data_10']
  belongs_to :user
  
  
  # Filter out the private attributes
  def public_attributes
    self.attribute_names.select{|a| !Profile::PRIVATE_FIELDS.include?(a)}
  end

end

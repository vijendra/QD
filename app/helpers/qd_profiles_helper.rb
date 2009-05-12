module QdProfilesHelper
  def table_header(qd_field)
    headers = {:listid => 'List Id', :fname => 'F Name', :mname => 'M Name', :lname => 'L Name', :address => 'Address', :city => 'City', :state => 'State', :zip => 'Zip', :zip4 => 'Zip4', :crrt => 'Crrt', :dpc => 'Dpc', :phone_num => 'Phone Num'}
    return "<th> #{headers[qd_field.to_sym]} </th>"
  end
end

class ShellDimension < ActiveRecord::Base
  belongs_to :administrator

  TEMPLATE1_FIELDS = {"dealer_x"=>"132", "third_para_y"=>"555", "sec_para_x"=>"50", "head_quarters_x"=>"50", "bg_color"=>"#FFFFFF", "dealer_y"=>"120", "sec_para_y"=>"620", "first_para_x"=>"50", "offer_x"=>"386", "note_x"=>"30", "first_para_y"=>"680", "offer_y"=>"835", "address_x"=>"115", "head_quarters_y"=>"920", "note_y"=>"250", "address_y"=>"810", "box_x"=>"50", "box_y"=>"460", "height"=>"1008", "dealer_details_x"=>"60", "date_x"=>"460", "dealer_details_y"=>"380", "date_y"=>"158", "third_para_x"=>"50", "width"=>"612"}
  TEMPLATE2_FIELDS = {"dealer_x"=>"135", "sec_para_x"=>"70", "bg_color"=>"#FFFFFF", "dealer_y"=>"130", "sec_para_y"=>"592", "first_para_x"=>"70", "offer_x"=>"377", "first_para_y"=>"687", "offer_y"=>"850", "address_x"=>"70", "rightbox4_x"=>"447", "rightbox1_x"=>"447", "address_y"=>"812", "rightbox4_y"=>"387", "rightbox2_x"=>"447", "rightbox1_y"=>"607", "rightbox3_x"=>"447", "rightbox2_y"=>"547", "rightbox3_y"=>"457", "height"=>"1008", "dealer_details_x"=>"60", "date_x"=>"462", "dealer_details_y"=>"290", "date_y"=>"163", "width"=>"612"}
  TEMPLATE3_FIELDS = {"third_para_y"=>"698", "sec_para_x"=>"77", "bg_color"=>"#FFFFFF", "sec_para_y"=>"813", "first_para_x"=>"77", "address_x"=>"110", "first_para_y"=>"875", "rightbox1_x"=>"405", "address_y"=>"148", "rightbox2_x"=>"449", "rightbox1_y"=>"740", "rightbox3_x"=>"449", "rightbox2_y"=>"670", "rightbox3_y"=>"610", "height"=>"1008", "dealer_details_x"=>"100", "dealer_details_y"=>"620", "third_para_x"=>"77", "width"=>"612"}
  TEMPLATE4_FIELDS = {"bg_color"=>"#FFFFFF", "address_x"=>"550", "address_y"=>"487", "height"=>"807", "dealer_details_x"=>"60", "dealer_details_y"=>"760", "width"=>"1267"}


  def self.dimensions_detail_for_template(administrator, template)
    eval("ShellDimension::TEMPLATE#{template}_FIELDS").each_pair {|key, value|
      if administrator.shell_dimensions.find_by_template_and_variable(template, key).blank?
        administrator.shell_dimensions.create(:template => template, :variable => key, :value => value)
      end
    }
  end

end


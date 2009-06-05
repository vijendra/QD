class AddFieldsToDealer < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :text_body_1, :text
  	add_column :profiles, :text_body_2, :text
  	add_column :profiles, :text_body_3, :text

  	add_column :profiles, :variable_data_4, :string
  	add_column :profiles, :variable_data_5, :string
  	add_column :profiles, :variable_data_6, :string
  	add_column :profiles, :variable_data_7, :string
  	add_column :profiles, :variable_data_8, :string
  	add_column :profiles, :variable_data_9, :string


  end

  def self.down
  end
end

class AddFieldsToTriggerDetail < ActiveRecord::Migration
  def self.up
    add_column :trigger_details, :file_id , :string
    add_column :trigger_details, :file_password , :string
    add_column :trigger_details, :file_url , :string
    add_column :trigger_details, :status , :string
  end

  def self.down
  end
end

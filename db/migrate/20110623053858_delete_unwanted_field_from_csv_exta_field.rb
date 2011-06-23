class DeleteUnwantedFieldFromCsvExtaField < ActiveRecord::Migration
  def self.up
   unused_fields = ['he_lendername', 'mtg_lendername', 'rev16', 'rev24', 'mktval02_range', 'mktval02', 'fhamtgbal', 'bk_filing_date', 'bk_status']
    DealerField.find(:all).each do |df|
      used_fields = df.fields - unused_fields
      df.update_attribute('fields', used_fields)
    end

    CsvExtraField.find(:all).each do |df|
      used_fields = df.fields - unused_fields
      df.update_attribute('fields', used_fields)
    end

  end

  def self.down
  end
end


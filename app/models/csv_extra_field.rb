class CsvExtraField < ActiveRecord::Base
	serialize :fields, Array
	belongs_to :dealer
end

class String
  def validate(regex, delimiter=',')
    invalid_items = []
    items = self.split(delimiter).collect(&:strip).uniq
    items.each do |item|
      invalid_items << item unless item =~ regex
    end
    unless invalid_items.empty?
      yield items, invalid_items
    end
  end
end

module DigitalToniq
  module ActiveRecordExtensions

  end
end

ActiveRecord::Base.send(:extend, DigitalToniq::ActiveRecordExtensions)
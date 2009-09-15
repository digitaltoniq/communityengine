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

# Plug run_later in at the mailer level to avoid sloshing through all
# references to Mailer.deliver_xxx
ActionMailer::Base.send(:include, RunLater::InstanceMethods)
module ActionMailer
  class Base
    def deliver_with_run_later!(mail = @mail)
      run_later { deliver_without_run_later!(mail) }
    end    
    alias_method_chain :deliver!, :run_later
  end
end

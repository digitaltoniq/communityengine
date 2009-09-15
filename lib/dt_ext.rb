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

    # Add run_later to these types of deliveries
    # NOTE: This is better placed as an alias of Mailer::Base.deliver!, but
    # that obscures our attempt to turn off Mailer::Base.perform_deliveries so
    # have to dive down another level to the specific delivery types
    [:sendmail, :smtp].each do |mail_type|
      class_eval <<-EOV
        def perform_delivery_#{mail_type}_with_run_later(*args)
          run_later { perform_delivery_#{mail_type}_without_run_later(*args) }
        end
        alias_method_chain :perform_delivery_#{mail_type}, :run_later
      EOV
    end
  end
end

# Be able to turn off mailing (i.e. during demo data creation)
module ActionMailer
  class Base
    def self.no_deliveries
      previous = perform_deliveries
      self.perform_deliveries = false
      returning(yield) { self.perform_deliveries = previous }
    end
  end
end

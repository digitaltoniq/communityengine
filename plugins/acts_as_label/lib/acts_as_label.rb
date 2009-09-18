module DT
  module Acts #:nodoc:
    module Label #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_label
          include DT::Acts::Label::InstanceMethods
          extend DT::Acts::Label::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
      end
      
      # This module contains instance methods
      module InstanceMethods

        # Quick way to add convenient to_s functionality.
        # Default format is label, of which a to_label method is auto provided.
        # The following should work out of the box:
        #   item.to_s #=> (label form)
        #   item.to_s(:label) #=> (label form)
        #   item.to_s(:inspect) #=> (inspection form)
        #   item.to_s(:form) #=> (invokes item.to_form)
        def to_s(format = :label)
          to_s_method = "to_#{format}"
          return self.send(to_s_method) if self.respond_to?(to_s_method)
          case format
            when :inspect then inspect
            else to_s
          end
        end

        def to_label
          label_field = [:label, :name, :full_name, :username, :login, :title].detect { |f| self.respond_to?(f) }
          label_field ? self.send(label_field) : self.to_s
        end
      end
    end
  end
end

module DT
  module Acts #:nodoc:
    module Likeable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_likeable
          has_many :likes, :as => :likeable, :dependent => :delete_all
          include DT::Acts::Likeable::InstanceMethods
          extend DT::Acts::Likeable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
      end
      
      # This module contains instance methods
      module InstanceMethods
      end
    end
  end
end

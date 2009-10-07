# Provide convenience methods around a default attachment managed within the
# attachment_fu universe (to give us all the benefits of having the same
# thumbnail sizes as our non-default attachments).  Requires a boolean :default
# column.
module DT
  module Attachment #:nodoc:
    module Default #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def has_default_attachment(opts = {})

          named_scope :defaults, :conditions => { :default => true }

          class_inheritable_accessor :default_attachment_opts
          self.default_attachment_opts = { :file => "#{Rails.root}/public/images/default_#{self.to_s.underscore.downcase}.gif" }.merge(opts)
          include DT::Attachment::Default::InstanceMethods
          extend DT::Attachment::Default::SingletonMethods
        end
      end

      # This module contains class methods
      module SingletonMethods

        # This is really ugly - controller resources in the model.
        # TODO: Anyway to use a normal File to represent uploaded data?
        def create_default
          file = default_attachment_opts[:file]
          if file
            require 'action_controller/test_process.rb'
            mimetype = `file -b --mime #{file}`.gsub(/\n/,"")
            data = ActionController::TestUploadedFile.new(file, mimetype)
            default = new(:uploaded_data => data)
            default.default = true # Not mass-assignable - have to hack attachment_fu otherwise
            default.save ? default : nil
          end
        end
        
        def default
          @default ||= (defaults.first || create_default)
        end

        def default?; !default.nil?; end
      end

      # This module contains instance methods
      module InstanceMethods
      end
    end
  end
end

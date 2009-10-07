require 'default_attachment'

ActiveRecord::Base.class_eval do
  include DT::Attachment::Default
end

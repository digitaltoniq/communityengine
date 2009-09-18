require 'acts_as_label'
ActiveRecord::Base.class_eval do
  include DT::Acts::Label
end

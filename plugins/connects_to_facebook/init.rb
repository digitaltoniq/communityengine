require 'connects_to_facebook'

ActiveRecord::Base.class_eval do
  include DT::ConnectsToFacebook
end
require 'acts_as_likeable'
require 'can_like_stuff'
ActiveRecord::Base.class_eval do
  include DT::Acts::Likeable
  include DT::Can::LikeStuff
end

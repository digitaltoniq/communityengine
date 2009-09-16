User.class_eval do
  can_like_stuff  
end

Comment.class_eval do
  acts_as_likeable
end

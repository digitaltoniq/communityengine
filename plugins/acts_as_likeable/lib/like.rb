class Like < ActiveRecord::Base

  # TODO: Make this side of relationship polymorphic as well (can_like)?
  belongs_to :user
  belongs_to :likeable, :polymorphic => true

  named_scope :for, lambda { |likeable|
    { :conditions => { :likeable_id => likeable.id, :likeable_type => likeable.class.to_s } }
  }
  named_scope :by, lambda { |user| { :conditions => { :user_id => user.id }}}
  
end

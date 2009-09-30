class Like < ActiveRecord::Base

  # TODO: Make this side of relationship polymorphic as well (can_like)?
  belongs_to :user
  belongs_to :likeable, :polymorphic => true

  # TODO: Breaks when more than a comment can be likeable
  acts_as_activity :user, :about => proc { |l| Company.for_comment(l.likeable) }

  named_scope :for, lambda { |likeable|
    { :conditions => { :likeable_id => likeable.id, :likeable_type => likeable.class.to_s } }
  }
  named_scope :by, lambda { |user| { :conditions => { :user_id => user.id }}}
  
end

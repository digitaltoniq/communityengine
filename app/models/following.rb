class Following < ActiveRecord::Base
  belongs_to :followed, :polymorphic => true
  belongs_to :user

  named_scope :company_followings_by_user, lambda { |user|
    { :conditions => ["followed_type = ? AND user_id = ?", "Company", user.id] }
  }

  named_scope :post_followings_by_user, lambda { |user|
    { :conditions => ["followed_type = ? AND user_id = ?", "Posts", user.id] }
  }
end

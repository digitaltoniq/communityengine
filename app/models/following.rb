class Following < ActiveRecord::Base
  belongs_to :followed, :polymorphic => true
  belongs_to :user

  ## Named scopes

  named_scope :by_user, lambda { |user|
    { :conditions => ["user_id = ?", user.id] }
  }
  named_scope :by_company, lambda { |company|
    { :conditions => ["followed_id = ?", company.id] }
  }
  named_scope :for_companies, :conditions => ["followed_type = ?", "Company"]
  named_scope :for_posts, :conditions => ["followed_type = ?", "Post"]
  named_scope :limited, lambda { |*limit|
    { :limit => limit.empty? ? 4 : limit }
  }
end

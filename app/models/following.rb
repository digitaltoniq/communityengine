class Following < ActiveRecord::Base
  belongs_to :followee, :polymorphic => true
  belongs_to :user

  # validation
  validates_presence_of     :user, :followee
  validates_uniqueness_of   :followee_id, :scope => :user_id

  ## Named scopes

  # TODO: need to support representative following, as well. Should we remove all Followee typing and just pass in?

  named_scope :by_user, lambda { |user|
    { :conditions => ["user_id = ?", user.id] }
  }
  named_scope :by_company, lambda { |company|
    { :conditions => ["followee_id = ?", company.id] }
  }
  named_scope :for_companies, :conditions => ["followee_type = ?", "Company"]
  named_scope :for_posts, :conditions => ["followee_type = ?", "Post"]
  named_scope :limited, lambda { |*limit|
    { :limit => limit.empty? ? 4 : limit }
  }

  def self.following_for(followee, follower)
    find(:first, :conditions => ["followee_id = ? AND user_id = ? AND followee_type = ?", followee.id, follower.id, followee.class.name])
  end

  def self.following_exist?(followee, follower)
    following_for(followee, follower)
  end

  def self.can_follow?(followee, follower)
    not following_exist?(followee, follower)
  end
end

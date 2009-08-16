class Following < ActiveRecord::Base
  belongs_to :followee, :polymorphic => true
  belongs_to :user

#  @@daily_request_limit = 12
#  cattr_accessor :daily_request_limit

  # validation
  validates_presence_of     :user, :followee
  validates_uniqueness_of   :followee_id, :scope => :user_id

#  TODO
#  def validate
#    if new_record? && user.has_reached_daily_friend_request_limit?
#      errors.add_to_base("Sorry, you'll have to wait a little while before requesting any more friendships.")
#    end
#  end

  # TODO after_save :notify_followee # use runs_later

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

  def self.can_follow(followee, follower)
    not following_exist?(followee, follower)
  end

  # TODO: needed?
  def notify_followee
    UserNotifier.deliver_following_notice(self)
  end
end

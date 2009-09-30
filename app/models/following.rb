class Following < ActiveRecord::Base
  belongs_to :followee, :polymorphic => true
  belongs_to :user

  # validation
  validates_presence_of     :user, :followee
  validates_uniqueness_of   :followee_id, :scope => :user_id

  acts_as_activity :user, :about => proc { |f|
    case f.followee.class.to_s
      when 'Company' then f.followee
      when 'Post' then Company.for_post(f.followee)
      else nil
    end
  }

  ## Named scopes

  # TODO: need to support representative following, as well. Should we remove all Followee typing and just pass in?
  named_scope :by, lambda { |user|
    { :conditions => { :user_id => user.id } }
  }
  named_scope :for, lambda { |followee|
    { :conditions => { :followee_type => followee.class.to_s, :followee_id => followee.id }}
  }
  named_scope :for_companies, :conditions => { :followee_type => Company.to_s }
  named_scope :for_posts, :conditions => { :followee_type => Post.to_s }

  # TODO: Shouldn't need this - instead use association (user.followings.for)
  def self.following_for(followee, follower)
    self.by(follower).for(followee).first
  end

  def self.following_exist?(followee, follower)
    following_for(followee, follower)
  end

  def self.can_follow?(followee, follower)
    not following_exist?(followee, follower)
  end

  def self.follow!(follower, followee)
    create(:user => follower, :followee => followee) if can_follow?(followee, follower)
  end
end

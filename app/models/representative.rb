class Representative < ActiveRecord::Base
  acts_as_label
   
  acts_as_activity :user, :about => :company
  tracks_unlinked_activities [:updated_profile]

  attr_protected :representative_role_id

  #validation

  validates_presence_of :company, :user, :representative_role

  #-- Callbacks
  before_validation :set_representative_role

  #associations
  has_enumerated :representative_role
  belongs_to :user
  belongs_to :company
  has_many :followings, :as => :followee

  delegate :password_confirmation, :password_confirmation=, :to => :user

  #  TODO: Note, method_missing will not work, attributes= fails, etc.
  delegate :avatar_photo_url, :this_months_posts, :last_months_posts,
           :recent, :active?, :tagged_with, :invite_code, :invite_code=, :birthday, :birthday=,
           :gender, :gender=, :login, :login=, :email, :email=, :password, :password=, :password_confirmation, :password_confirmation=,
           :zip, :zip=, :description, :description=, :country, :country=, :state, :state=, :metro_area, :metro_area=,
           :invitations, :posts, :photos, :avatar, :avatar=, :tag_list, :tag_list=, :role, :role=,
           :comments_as_author, :comments_as_recipient, :clippings, :favorites, :followings,
           :first_name, :last_name, :first_name=, :last_name=, :full_name, :to_param, :to => :user
  delegate :location, :full_location, :to => :company

  #named scopes
  named_scope :recent, :order => 'representatives.created_at DESC'
  named_scope :active, :conditions => ["users.activated_at IS NOT NULL"],
              :joins => "left join users on representatives.user_id = users.id"
  named_scope :for_users, lambda { |*users_or_ids|
    { :conditions => users_or_ids.any? ? ["user_id IN (?)", users_or_ids.flatten] : '1 = 0'}
  }

  ## Class Methods

  class << self

    # Get all users that are reps
    def users
      User.scoped :joins => "left join representatives on representatives.user_id = users.id"
    end

    def for_user(user_or_id)
      find_by_user_id(user_or_id)
    end

    # Get the rep whose post this comment is on
    def for_comment_post(comment)
      if comment.commentable_type == Post.to_s
        for_user(comment.commentable.user_id)
      end
    end
  end

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      Representative.for_user(User.find(*args))
    else
      super
    end
  end

  # Get the reps participating in the given post/commentable (minus the author of
  # the post) who belong to the company of the author.
  # NOTE: This could be a named_scope for more flexibility, but would run into issues
  # with count operator b/c of group/distinct clauses.
  def self.participating_in(commentable)
    if(company = Representative.for_user(commentable.user).try(:company))
      company.representatives.find(:all,
                                   :joins => "RIGHT JOIN comments ON representatives.user_id = comments.user_id",
                                   :conditions => ["comments.user_id != ? AND comments.commentable_id = ? AND commentable_type = ?",
                                                   commentable.user.id, commentable.id, commentable.class.to_s],
                                   :group => "comments.user_id")
    else
      []
    end
  end

  ## Instance Methods

  # TODO: discuss, working?  No, can't entirely work like rails delegate method can, doesn't handle attributes= correctly
  def method_missing(method, *args, &block)
    self.user.__send__(method, *args, &block)
  rescue
    super
  end

  def attributes=(new_attributes, guard_protected_attributes = true)
    # ensure user delegate is available before setting attributes
    self.user = new_attributes[:user] || User.new unless self.user
    super
  end

  # TODO: Shouldn't these be handled by has_enumerated?
  def representative?
    true # TODO: update when more than one role
#    !representative_role || representative_role.eql?(RepresentativeRole[:representative])
  end

  # TODO: Not sure this is necessary as dependent has_one associations are already saved?
  def after_save
    user.save
  end
  
  def validate
    user.valid?
    user.errors.each { |attr, msg| errors.add(attr, msg) }
  end

  # If this is the first guy in the front door, he's the admin
  def set_representative_role
    if !representative_role_id
      self.representative_role = RepresentativeRole[:representative]
    end
  end
end

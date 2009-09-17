class Representative < ActiveRecord::Base
  acts_as_slugable :source_column => :full_name, :scope => :company

  attr_protected :representative_role_id

  # TODO: need additional activities tracked? tracks_unlinked_activities [:xyz]    

  #validation

  validates_presence_of :company, :user
  validates_length_of   :first_name, :within => 1..30
  validates_length_of   :last_name,  :within => 2..30 
  validates_each :email do |record, attr, email|
    # TODO: better message, localize
    record.errors.add(:email, " domain of email address not related to your company") unless record.company.accepts_email?(email)
  end

  #associations
  has_enumerated :representative_role
  belongs_to :user
  belongs_to :company
  has_many   :representative_invitations
  has_many :followings, :as => :followee

  delegate :password_confirmation, :password_confirmation=, :to => :user

  #  TODO: Note, method_missing will not work, attributes= fails, etc.
  delegate :avatar_photo_url, :this_months_posts, :last_months_posts, :location, :full_location,
           :recent, :active, :tagged_with, :invite_code, :invite_code=, :birthday, :birthday=,
           :login, :login=, :email, :email=, :password, :password=, :password_confirmation, :password_confirmation=,
           :zip, :zip=, :description, :description=, :country, :country=, :state, :state=, :metro_area, :metro_area=,
           :invitations, :posts, :photos, :avatar, :avatar=, :tag_list, :tag_list=, :role, :role=,
           :comments_as_author, :comments_as_recipient, :clippings, :favorites, :followings, :to => :user

  #named scopes
  named_scope :recent, :order => 'representatives.created_at DESC'
  named_scope :active, :conditions => ["users.activated_at IS NOT NULL"],
              :joins => "left join users on representatives.user_id = users.id"

  ## Class Methods

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_url_slug(args)
    else
      super
    end
  end

  def self.for_user(user)
    find_by_user_id(user.id )
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

  def full_name
    "#{first_name} #{last_name}"
  end

  def name
    full_name
  end

  def to_param
    url_slug || id
  end

  def attributes=(new_attributes, guard_protected_attributes = true)
    # ensure user delegate is available before setting attributes
    self.user = new_attributes[:user] || User.new unless self.user
    super
  end

  # TODO: These need to be protected? They were in CE

  def admin?
    representative_role && representative_role.eql?(RepresentativeRole[:admin])
  end

  def poster?
    representative_role && representative_role.eql?(RepresentativeRole[:poster])
  end

  def representative?
    !representative_role || representative_role.eql?(RepresentativeRole[:representative])
  end

  def after_save
    user.save
  end
  
  def validate
    user.valid?
    user.errors.each { |attr, msg| errors.add(attr, msg) }
  end
end

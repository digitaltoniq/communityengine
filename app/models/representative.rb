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

  #  TODO: consider method_missing approach...
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

  ## Instance Methods

  # TODO: discuss, working?
  def method_missing_with_user_delegation(method, *args, &block)
    self.user.__send__(method, *args, &block)
  rescue
    method_missing_without_user_delegation(method, *args, &block)
  end

  alias_method_chain :method_missing, :user_delegation    # TODO: shouldn't need chaining

  def full_name
    "#{first_name} #{last_name}"
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
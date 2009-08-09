class Representative < ActiveRecord::Base
  acts_as_slugable :source_column => :full_name, :scope => :company
  
  attr_protected :representative_role_id

  #validation

  #associations
  has_enumerated :representative_role
  belongs_to :user
  belongs_to :company
  has_many   :representative_invitations

  delegate :avatar_photo_url, :this_months_posts, :last_months_posts, :location, :full_location,
           :recent, :active, :tagged_with,
           :invitations, :posts, :photos, :avatar, :metro_area, :state, :country,
           :comments_as_author, :comments_as_recipient, :clippings, :favorites, :followings, :to => :user

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

  def full_name
    "#{first_name} #{last_name}"
  end

  def to_param
    url_slug || id
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
end
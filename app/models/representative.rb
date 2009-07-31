class Representative < ActiveRecord::Base
  belongs_to :user
  belongs_to :company 

  #validation
  # TODO (unique in context of company) validates_uniqueness_of :generate_full_name_slug  -

  # callbacks
  before_save :generate_full_name_slug
  
  delegate :avatar_photo_url, :posts, :to => :user

  def full_name
    "#{first_name} #{last_name}"
  end

  def to_param
    full_name_slug || id
  end

  # before filter
  def generate_full_name_slug
    self.full_name_slug = self.full_name.gsub(/[^a-z0-9]+/i, '-')
  end


  ## Class Methods

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_full_name_slug(args)
    else
      super
    end
  end

end
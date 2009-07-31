class Company < ActiveRecord::Base 
  acts_as_taggable
  acts_as_commentable
  has_private_messages
  tracks_unlinked_activities [:logged_in, :invited_friends, :updated_profile, :joined_the_site]

  #callbacks
  before_save   :generate_name_slug

  # validation
  validates_length_of       :name,      :within => 1..100
  validates_uniqueness_of   :name,      :case_sensitive => false
  # TODO validates_format_of       :name,      :with => /^[\sA-Za-z0-9_-]+$/
  # TODO validates_exclusion_of    :name, :in => AppConfig.reserved_company_names
  validates_presence_of     :metro_area,                 :if => Proc.new { |user| user.state }
  validates_uniqueness_of   :name_slug


  #associations
  has_many    :representatives, :dependent => :destroy
  
  belongs_to  :logo, :class_name => "Logo", :foreign_key => "logo_id"
  belongs_to  :metro_area
  belongs_to  :state
  belongs_to  :country

  #named scopes
  named_scope :recent, :order => 'companies.created_at DESC'


  def logo_photo_url(size = nil)
    if logo
      logo.public_filename(size)
    else
      case size
        when :thumb
          AppConfig.photo['missing_thumb']   # TODO: use logo
        else
          AppConfig.photo['missing_medium']
      end
    end
  end

  def to_param
    name_slug
  end

   # before filter
  def generate_name_slug
    self.name_slug = self.name.gsub(/[^a-z0-9]+/i, '-')
  end

  ## Class Methods

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_name_slug(args)
    else
      super
    end
  end

end

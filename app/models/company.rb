class Company < ActiveRecord::Base
  acts_as_slugable :source_column => :name
  tracks_unlinked_activities [:updated_profile, :joined_the_site]
  acts_as_label

  # validation
  validates_length_of       :name,      :within => 1..100
  validates_length_of       :description,      :maximum => 300, :allow_blank => true
  validates_uniqueness_of   :name,      :case_sensitive => false
#  validates_format_of       :name,      :with => /^[\sA-Za-z0-9'_,-]+$/
  validates_exclusion_of    :url_slug, :in => AppConfig.reserved_company_names
  # validates_presence_of     :metro_area,                 :if => Proc.new { |user| user.state }
  validates_uniqueness_of   :url_slug
  validates_format_of       :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :allow_blank => true

#  validates_presence_of     :domains
#
#  validates_each :domains do |record, attr, domain_csv|
#    domain_csv && domain_csv.validate(/((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i) do |domains, invalid_domains|
#      record.errors.add(:domains, " included invalid domains: #{invalid_domains.join(", ")}")
#    end
#  end

  #associations
  has_many    :representatives, :dependent => :destroy
  has_many    :followings, :as => :followee
  has_many :followers, :through =>:followings, :source => :user
  has_many   :representative_invitations
  
  belongs_to  :logo, :class_name => "Logo", :foreign_key => "logo_id"
  belongs_to  :metro_area
  belongs_to  :state
  belongs_to  :country

  #named scopes
  named_scope :recent, :order => 'companies.created_at DESC'

  ## Class Methods

  class << self

    # Get a Post scope for all posts by a company rep
    def posts
      Post.scoped :joins => "left join representatives on representatives.user_id = posts.user_id"
    end

    # Get a Post scope for all posts for the given companies
    def posts_in(*companies)
      company_ids = companies.flatten.collect(&:id)
      company_ids.any? ?
              posts.scoped(:conditions => ["representatives.company_id IN (?)", company_ids]) :
              Post.scoped(:conditions => '1 = 0')
    end

    # TODO: will need to update when more than just posts can be commented on
    def for_comment(comment)
      for_post(comment.commentable)
    end

    def for_post(post)
      rep = Representative.for_user(post.user_id)
      rep.company if rep
    end

    def for_user(user)
      rep = Representative.for_user(user)
      rep.company if rep
    end

    def recently_active(opts = {})
      since = opts[:since] || 5.days.ago
      Activity.since(since).
              about_type(self).
              find(:all,
                   :select => 'activities.about_id, activities.about_type, count(*) as count',
                   :group => 'activities.about_id',
                   :order => 'count DESC',
                   :include => :about,
                   :limit => (opts[:limit] || 30)).collect(&:about)
    end
  end

  # override activerecord's find to allow us to find by name or id transparently
  # TODO: factor this out, needed for anything slugged
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_url_slug(args)
    else
      super
    end
  end

  ## Instance Methods

#  def accepts_email?(email)
#    email && email.include?("@") && domains.downcase.include?(email.split('@').last.downcase)
#  end

  def posts

    # TODO: Have to do this to avoid getting back readonly posts?
    ids = self.class.posts_in(self).find(:all, :select => 'posts.id').collect(&:id)
    Post.scoped(:conditions => (ids.any? ? ["posts.id IN (?)", ids] : '1 = 2'))
  end

  def post_comments
    Comment.scoped :joins => "left join posts on comments.commentable_id = posts.id left join representatives on representatives.user_id = posts.user_id",
                :conditions => ["representatives.company_id = ? AND comments.commentable_type = ?", id, Post.to_s]
  end

  def representative_comments
    Comment.scoped :joins => "left join representatives on representatives.user_id = comments.user_id",
                :conditions => ["representatives.company_id = ? AND comments.commentable_type = ?", id, Post.to_s]
  end
  
  def logo_photo_url(size = nil)
    if logo
      logo.public_filename(size)
    else
      Logo.default.public_filename(size)
    end
  end

  def to_param
    url_slug || id
  end

  # Can the given user administer this company?
  def admin?(user)
    user.admin? or representative_for_user(user)
  end

  # Can the given user invite others to this company?
  def invite?(user)
    admin?(user)
  end

  # Can the given user post convos to this company?
  def post?(user)
    admin?(user)
  end

  def representative_for_user(user)
     representatives.find(:first, :conditions => ["user_id = ?", user.id])
  end

  def representative?(user)
    !representative_for_user(user).nil?
  end

  def location
    metro_area && metro_area.name || ""
  end

  def full_location
    "#{metro_area.name if self.metro_area}#{" , #{self.country.name}" if self.country}"
  end
end

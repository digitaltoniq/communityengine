class Company < ActiveRecord::Base
  acts_as_slugable :source_column => :name
  acts_as_taggable
  acts_as_commentable
  has_private_messages
  tracks_unlinked_activities [:updated_profile, :joined_the_site]
  acts_as_label

  # validation
  validates_length_of       :name,      :within => 1..100
  validates_uniqueness_of   :name,      :case_sensitive => false
#  validates_format_of       :name,      :with => /^[\sA-Za-z0-9'_,-]+$/
  validates_exclusion_of    :url_slug, :in => AppConfig.reserved_company_names
  # validates_presence_of     :metro_area,                 :if => Proc.new { |user| user.state }
  validates_uniqueness_of   :url_slug
  validates_presence_of     :domains
 
  validates_each :domains do |record, attr, domain_csv|
    domain_csv && domain_csv.validate(/((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i) do |domains, invalid_domains|
      record.errors.add(:domains, " included invalid domains: #{invalid_domains.join(", ")}")
    end
  end

  #associations
  has_many    :representatives, :dependent => :destroy
  has_many    :followings, :as => :followee
  
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

    def register_activity(activity_item)
      company = case activity_item.class.to_s
        when 'Comment' then for_comment(activity_item)
        when 'Post' then for_post(activity_item)
      end
      Activity.create(:item => company, :user_id => activity_item.user_id,
                      :action => "#{activity_item.class.to_s.downcase}_published")
    end

    # TODO: will need to update when more than just posts can be commented on
    def for_comment(comment)
      for_post(comment.commentable)
    end

    def for_post(post)
      rep = Representative.for_user(post.user_id)
      rep.company if rep
    end

    def recently_active(opts = {})
      since = opts[:since] || 5.days.ago
      Activity.since(since).
              of_item_type('Company').
              find(:all,
                   :select => 'activities.item_id, activities.item_type, count(*) as count',
                   :group => 'activities.item_id',
                   :order => 'count DESC',
                   :include => :item,
                   :limit => (opts[:limit] || 30)).collect(&:item)
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

  def accepts_email?(email)
    email && email.include?("@") && domains.downcase.include?(email.split('@').last.downcase)
  end

  def posts
    self.class.posts_in(self)
  end

  def post_comments
    Comment.scoped :joins => "left join posts on comments.commentable_id = posts.id left join representatives on representatives.user_id = posts.user_id",
                :conditions => ["representatives.company_id = ?", id]
  end 
  
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
    url_slug || id
  end

  def representative_for_user(user)
     representatives.find(:first, :conditions => ["user_id = ?", user.id])
  end

  def company_admin?(user)
    r = representative_for_user(user)
    r && r.admin?
  end

  def location
    metro_area && metro_area.name || ""
  end

  def full_location
    "#{metro_area.name if self.metro_area}#{" , #{self.country.name}" if self.country}"
  end
end

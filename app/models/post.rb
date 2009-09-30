class Post < ActiveRecord::Base
  acts_as_commentable
  acts_as_taggable
  acts_as_activity :user, :if => Proc.new{|r| r.is_live?}, :about => proc { |p| Company.for_post(p) }
  acts_as_publishable :live, :draft
  acts_as_label

  attr_accessor :feature_image_id

  belongs_to :user
  belongs_to :category
  belongs_to :contest
  has_many   :polls, :dependent => :destroy
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :followings, :as => :followee
  has_many :followers, :through =>:followings, :source => :user
  has_one :feature_image, :dependent => :destroy
  
  validates_presence_of :raw_post
  validates_presence_of :title
  validates_presence_of :user
  validates_presence_of :published_at, :if => Proc.new{|r| r.is_live? }

  before_save :transform_post
  before_validation :set_published_at
  
  after_save do |post|
    activity = Activity.find_by_item_type_and_item_id('Post', post.id)
    if post.is_live? && !activity
      post.create_activity_from_self 
    elsif post.is_draft? && activity
      activity.destroy
    end
  end

  after_save :link_feature_image

  attr_accessor :invalid_emails
  
  #Named scopes
  named_scope :by_featured_writers, :conditions => ["users.featured_writer = ?", true], :include => :user
  named_scope :recent, :order => 'posts.published_at DESC'
  named_scope :popular, :order => 'posts.view_count DESC'
  named_scope :since, lambda { |days|
    {:conditions => "posts.published_at > '#{days.ago.to_s :db}'" }
  }
  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["tags.name = ?", tag_name], :include => :tags}
  }

  # Make sure we have a feature_image to hook up with after saving.
  # NOTE: Will need to mock this if not going through web form, i.e. in factory
  def validate
    errors.add(:feature_image, "must be uploaded") if feature_image_id.blank? and !feature_image
  end
  
  def self.find_related_to(post, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'published_at DESC', 
        :conditions => [ 'posts.id != ? AND published_as = ?', post.id, 'live' ]
    })

    find_tagged_with(post.tag_list, merged_options).uniq
  end

  def to_param
    id.to_s << "-" << (title ? title.parameterize : '' )
  end

  def self.find_recent(options = {:limit => 5})
    self.recent.find :all, :limit => options[:limit]
  end
  
  def self.find_popular(options = {} )
    options.reverse_merge! :limit => 5, :since => 7.days
    
    self.popular.since(options[:since]).find :all, :limit => options[:limit]
  end

  def self.find_featured(options = {:limit => 10})
    self.recent.by_featured_writers.find(:all, :limit => options[:limit] )    
  end

  def self.find_most_commented(limit = 10, since = 7.days.ago)
    Post.find(:all, 
      :select => 'posts.*, count(*) as comments_count',
      :joins => "LEFT JOIN comments ON comments.commentable_id = posts.id",
      :conditions => ['comments.commentable_type = ? AND posts.published_at > ?', 'Post', since],
#      :group => 'comments.commentable_id',      
      :group => self.columns.map{|column| self.table_name + "." + column.name}.join(","),
      :order => 'comments_count DESC',
      :limit => limit
      )
  end

  def display_title
    t = self.title
    if self.category
      t = self.category.name.upcase << ": " << t
    end
    t
  end
  
  def previous_post
    self.user.posts.find(:first, :conditions => ['published_at < ? and published_as = ?', published_at, 'live'], :order => 'published_at DESC')
  end
  def next_post
    self.user.posts.find(:first, :conditions => ['published_at > ? and published_as = ?', published_at, 'live'], :order => 'published_at ASC')
  end
  
  def first_image_in_body(size = nil, options = {})
    doc = Hpricot( post )
    image = doc.at("img")
    image ? image['src'] : nil
  end
  
  def tag_for_first_image_in_body
    image = first_image_in_body
    image.nil? ? '' : "<img src='#{image}' />"
  end
  
  ## transform the text and title into valid html
  def transform_post
   # self.raw_post  = force_relative_urls(self.raw_post)
   self.post  = white_list(self.raw_post)
   self.title = white_list(self.title)
  end
  
  def set_published_at
    if self.is_live? && !self.published_at
      self.published_at = Time.now
    end
  end
  
  def owner
    self.user
  end
  
  def send_to(email_addresses = '', message = '', user = nil)
    self.invalid_emails = []
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each do |email|      
      self.invalid_emails << email unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
    end
    if email_addresses.blank? || !invalid_emails.empty?
      return false
    else    
      emails = email_addresses.split(",").collect{|email| email.strip }.uniq 
      emails.each{|email|
        UserNotifier.deliver_post_recommendation((user ? user.login : 'Someone'), email, self, message, user)
      }
      self.increment(:emailed_count).save    
    end
  end
  
  def self.new_from_bookmarklet(params)
    self.new(
      :title => "#{params[:title] || params[:uri]}",
      :raw_post => "<a href='#{params[:uri]}'>#{params[:uri]}</a>#{params[:selection] ? "<p>#{params[:selection]}</p>" : ''}"
      )
  end

  def photo(size = :medium)
    feature_image ? feature_image.public_filename(size) : user.avatar_photo_url(size)
  end

  def image_for_excerpt
    first_image_in_body || user.avatar_photo_url(:medium)  
  end
  
  def create_poll(poll, choices)
    new_poll = self.polls.build(:question => poll[:question])
    choices.delete('')
    if choices.size > 1
      new_poll.save
      new_poll.add_choices(choices)
    end
  end
  
  def update_poll(poll, choices)
    return unless self.poll
    self.poll.update_attributes(:question => poll[:question])
    choices.delete('')
    if choices.size > 1
      self.poll.choices.destroy_all
      self.poll.save
      self.poll.add_choices(choices)
    else
      self.poll.destroy
    end
  end
  
  def poll
    !polls.empty? && polls.first
  end
  
  def has_been_favorited_by(user = nil, remote_ip = nil)
    f = Favorite.find_by_user_or_ip_address(self, user, remote_ip)
    return f
  end  

  def published_at_display(format = 'published_date')
    is_live? ? I18n.l(published_at, :format => format) : 'Draft'
  end

  def notify_company_followers
    company = Company.for_post(self)
    company.followers.each do |follower|
      UserNotifier.deliver_following_company_post_notice(follower, company, self)
    end if company
  end

  def send_notifications
    notify_company_followers
  end

  private

  def link_feature_image
    self.feature_image = FeatureImage.find(feature_image_id) if feature_image_id
  end
      
end

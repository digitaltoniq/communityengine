require 'hpricot'
require 'open-uri'
require 'pp'

class BaseController < ApplicationController
  include AuthenticatedSystem
  include LocalizedApplication
  around_filter :set_locale  
  before_filter :login_from_cookie, :store_return_to
  skip_before_filter :verify_authenticity_token, :only => :footer_content
  helper_method :commentable_url
  helper_method :user_path, :post_path, :user_posts_path, :edit_user_path, :display_text, :dashboard_path # DigitalToniq

  caches_action :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('base') && params[:format].blank? 
  end  
  
  if AppConfig.closed_beta_mode
    before_filter :beta_login_required, :except => [:teaser]
  end    
  
  def teaser
    redirect_to home_path and return if logged_in?
    render :layout => 'beta'
  end
  
  def rss_site_index
    redirect_to :controller => 'base', :action => 'site_index', :format => 'rss'
  end
  
  def plaxo
    render :layout => false
  end

  def site_index    
    @posts = Post.recent.limited(10)
    @rss_title = "#{AppConfig.community_name} "+:recent_posts.l
    @rss_url = rss_url
    respond_to do |format|     
      format.html { get_additional_homepage_data }
      format.rss do
        render_rss_feed_for(@posts, { :feed => {:title => "#{AppConfig.community_name} "+:recent_posts.l, :link => recent_url},
                              :item => {:title => :title,
                                        :link =>  Proc.new {|post| user_post_url(post.user, post)},
                                         :description => :post,
                                         :pub_date => :published_at}
          })
      end
    end    
  end
  
  def footer_content
    get_recent_footer_content 
    render :partial => 'shared/footer_content' and return    
  end
  
  def homepage_features
    @homepage_features = HomepageFeature.find_features
    @homepage_features.shift
    render :partial => 'homepage_feature', :collection => @homepage_features and return
  end
    
  def about
  end
  
  def advertise
  end
  
  def faq
  end
  
  def css_help
  end
  
  def admin_required
    current_user && current_user.admin? ? true : access_denied
  end
  
  def admin_or_moderator_required
    current_user && (current_user.admin? || current_user.moderator?) ? true : access_denied
  end

  def determine_user
    # DT: If representative_id is given, determine the user and stuff params with the id 
    if params[:company_id]
      rep = Representative.find(params[:representative_id] || params[:id])
      if rep
        user = rep.user
        params[:user_id] = user.id
        return user
      end
    else
      return User.active.find(params[:user_id] || params[:id])
    end
  end

  def find_user
    if @user = determine_user
        @is_current_user = (@user && @user.eql?(current_user))
      unless logged_in? || @user.profile_public?
        flash[:error] = :this_users_profile_is_not_public_youll_need_to_create_an_account_and_log_in_to_access_it.l
        redirect_to :controller => 'sessions', :action => 'new'        
      end
      return @user
    else
      if logged_in?
        flash[:error] = :could_not_find_item.l(:item_name => controller_name.singularize)
        redirect_to application_url
      else
        flash[:error] = :please_log_in.l
        redirect_to :controller => 'sessions', :action => 'new'
      end
    end
  end
  
  def require_current_user
    @user ||= determine_user
    unless admin? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

  def require_representative
    @user ||= determine_user
    unless Representative.for_user(@user)
      flash[:error] = "We're sorry, only company representatives can post conversations"
      redirect_to application_path
    end
  end

  def popular_tags(limit = nil, order = ' tags.name ASC', type = nil)
    sql = "SELECT tags.id, tags.name, count(*) AS count 
      FROM taggings, tags 
      WHERE tags.id = taggings.tag_id "
    sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?      
    sql += " GROUP BY tags.id, tags.name"
    sql += " ORDER BY #{order}"
    sql += " LIMIT #{limit}" if limit
    Tag.find_by_sql(sql).sort{ |a,b| a.name.downcase <=> b.name.downcase}
  end
  

  def get_recent_footer_content
    @recent_clippings = Clipping.find_recent(:limit => 10)
    @recent_photos = Photo.find_recent(:limit => 10)
    @recent_comments = Comment.find_recent(:limit => 13)
    @popular_tags = popular_tags(30, ' count DESC')
    @recent_activity = User.recent_activity(:size => 15, :current => 1)
    
  end

  def get_additional_homepage_data
    @sidebar_right = true
    @homepage_features = HomepageFeature.find_features
    @homepage_features_data = @homepage_features.collect {|f| [f.id, f.public_filename(:large) ]  }    

    @active_companies = Company.recently_active(:limit => 5)
    @active_users = User.active.find_by_activity({:limit => 5, :require_avatar => false})
#    @featured_writers = User.find_featured

#    @featured_posts = Post.find_featured
    
#    @topics = Topic.find(:all, :limit => 5, :order => "replied_at DESC")

#    @active_contest = Contest.get_active
#    @popular_posts = Post.find_popular({:limit => 10})
#    @popular_polls = Poll.find_popular(:limit => 8)
  end


  def commentable_url(comment)
    if comment.commentable_type == 'Post'
      post_path(comment.commentable)+"#comment_#{comment.id}"
    elsif comment.recipient && comment.commentable
      if comment.commentable_type != "User"
        polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
      elsif comment
        user_url(comment.recipient)+"#comment_#{comment.id}"
      end
    elsif comment.commentable
      polymorphic_url(comment.commentable)+"#comment_#{comment.id}"      
    end
  end

  def commentable_comments_url(commentable)
    if commentable.owner && commentable.owner != commentable
      "#{polymorphic_path([commentable.owner, commentable])}#comments"      
    else
      "#{polymorphic_path(commentable)}#comments"      
    end    
  end  

  # DigitalToniq

  # TODO: patch model classes with to_label instead? Merge with with display_name used for representative unwinding, call this label
  def display_text(target)
    target.send [:title, :name, :login, :label, :text, :to_s].find { |m| target.respond_to? m }
  end

  # The following automatically routes user paths to representative paths if user is wrapped by representative
  def post_path(post)
    r = Representative.for_user(post.user_id)
    r ? company_representative_post_path(r.company, r, post) : user_post_path(post.user_id, post)
  end

  # TODO: add site admin support
  def dashboard_path(user)
    r = Representative.for_user(user)
    r ? dashboard_company_representative_path(r.company, r) : dashboard_user_path(user)
  end

  def user_path(user)
    r = user.class == User ? Representative.find_by_user_id(user.id) : nil # TODO: a view in CE is calling this with a hash, that valid?
    r ? company_representative_path(r.company, r) : super
  end

  def user_posts_path(user, *args)
    r = Representative.find_by_user_id(user.id)
    r ? company_representative_posts_path(r.company, r, *args) : super
  end

  def edit_user_path(user, *args)
    r = Representative.find_by_user_id(user.id)
    r ? edit_company_representative_path(r.company, r, *args) : super
  end
  # End user paths

  def ensure_valid_resource
    unless resource
      flash[:error] = :could_not_find_item.l(:item_name => resource_class.to_s.downcase)
      redirect_to application_path
    end
  end

end

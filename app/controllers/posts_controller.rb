class PostsController < BaseController

  # Trying to clean up RESTfully
  inherit_resources
  belongs_to :company, :user, :polymorphic => true
  respond_to :html, :js, :xml
  respond_to :rss, :only => [:index]

  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit, :update, :create ])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])
         
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  caches_action :show, :if => Proc.new {|c| !c.logged_in? }
  caches_action :popular, :if => Proc.new {|c| !c.logged_in? }
                           
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :manage]
  before_filter :require_representative_or_admin, :only => [:new, :create, :edit, :update, :destroy, :manage]
  before_filter :require_company_representative_or_admin, :only => [:new, :create, :edit, :update, :destroy, :manage]

  skip_before_filter :verify_authenticity_token, :only => [:update_views] #called from ajax on cached pages

  #-- CRUD --#

  def index
    index! do |format|
      format.html do
        @popular_posts = parent.posts.popular.limited(5)
        case parent_type
          when :company then render :action => 'company_index'
          when :user then render :action => 'user_index'
        end
      end
      format.rss do
        @rss_title = "#{AppConfig.community_name}: #{parent}'s conversations"
        @rss_url = collection_url
      end
    end
  end

  def show
    show! do |format|
      format.html do
        @comment = Comment.new(params[:comment])
        @comments = resource.comments.limited(25).ordered('created_at DESC').with(:user)
      end
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = :your_post_was_saved_back_to_editing.l(:edit_url => edit_company_post_path(@company, @post))
        submit_val = params[:commit].downcase
        view_post = (submit_val.include?('preview') or submit_val.include?('publish')) # TODO: hack?
        redirect_to(view_post ? post_path(@post) : manage_company_posts_path(@company))
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = :your_post_was_successfully_updated.l
        redirect_to @post.is_live? ? post_path(@post) : manage_company_posts_path(@company)
      end
    end
  end

  def destroy
    destroy! do
      flash[:notice] = :your_post_was_deleted.l
      manage_company_posts_path(@company)
    end
  end

  #-- Custom --#

  def popular
    @posts = Post.live.with(:user, :feature_image).find_popular({:limit => 10})
    respond_to do |format|
      format.html
      format.rss do
        @rss_title = "#{AppConfig.community_name} #{:popular_posts.l}"
        @rss_url = popular_posts_url(:format => :rss)
        render :action => 'index'
      end
    end
  end
  
  def manage
    @posts = end_of_association_chain.ordered('created_at DESC').with(:user).paginate(paging_params.merge(:per_page => 25))
    index!
  end
  
  def update_views
    render :text => update_view_count(resource) ? 'updated' : 'duplicate'
  end
  
  private

  #-- Inherited resources overrides --#

  def collection
    @posts ||= end_of_association_chain.live.with(:user, :feature_image).ordered('created_at DESC').paginate(paging_params)
  end

  def build_resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.send(method_for_build, {'published_as' => 'draft', 'user_id' => current_user.id}.merge(params[resource_instance_name] || {})))
  end

  #-- Filters --#

  def require_company_representative_or_admin
    unless @representative.nil? or @representative.company == (@company = Company.find(params[:company_id]))
      flash[:error] = "Only company representatives can access that page.  You belong to #{@representative.company} and this post belongs to #{parent}."
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end
end

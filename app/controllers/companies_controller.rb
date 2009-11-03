require "RMagick"

class CompaniesController < BaseController
  include Viewable

  # Trying to clean up RESTfully
  inherit_resources
  respond_to :html

  before_filter :ensure_valid_resource, :only => [:show, :dashboard, :edit, :update, :destroy, :activity, :post_comments, :representative_comments]

  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [])

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy, :dashboard, :activity]
  before_filter :admin_required, :only => [:new, :create, :destroy]

  before_filter :admin_or_company_admin_required, :only => [:edit, :update, :change_company_logo, :upload_company_logo
                                              #:welcome_photo, :welcome_about, :welcome_invite, :deactivate,
                                              # :crop_profile_photo
                                              ]
  before_filter :admin_or_company_representative_required, :only => [:dashboard, :activity]
  
   def index
     index! { get_additional_companies_page_data }
   end

  def dashboard
    redirect_to activity_company_path(resource)
#    @network_activity = Activity.about(resource).recent.limited(15)
#    respond_to(:with => resource)
  end
  
  def show
    # TODO: Move these auxiliary items up to view or filter?
    show! do
      @post_comments = @company.representative_comments.ordered('created_at DESC').limited(25)
      @recent_posts = @company.posts.ordered("published_at DESC").limited(2)
      update_view_count(@company) unless current_user && (@company.representative?(current_user) or current_user.admin?)
    end
  end
    
  def edit
    # TODO: Move out of controller
    edit! do
      @metro_areas, @states = setup_locations_for(@company)
      @logo = Logo.new
    end
  end

  # TODO: This is fugly, clean up.
  def update
    @company = Company.find(params[:id])
    @company.attributes = params[:company]
    @metro_areas, @states = setup_locations_for(@company)

    unless params[:metro_area_id].blank?
      @company.metro_area  = MetroArea.find(params[:metro_area_id])
      @company.state       = (@company.metro_area && @company.metro_area.state) ? @company.metro_area.state : nil
      @company.country     = @company.metro_area.country if (@company.metro_area && @company.metro_area.country)
    else
      @company.metro_area = @company.state = @company.country = nil
    end
  
    @logo       = Logo.new(params[:logo])
    @logo.company  = @company

    @company.logo  = @logo if @logo.save
    
    @company.tag_list = params[:tag_list] || ''

    if @company.save!
      @company.track_activity(:updated_profile)
      
      flash[:notice] = :your_changes_were_saved.l
      unless params[:welcome_company]
        redirect_to company_path(@company)
      else
        redirect_to :action => "welcome_#{params[:welcome_company]}", :id => @company
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  # TODO: Broken
  def destroy
    resource
    unless @company.admin?
      @company.destroy
      flash[:notice] = :the_company_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_company.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def change_company_logo
    @company   = Company.find(params[:id])
    @logo  = Logo.find(params[:logo_id])
    @company.logo = @logo

    if @company.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to company_logo_path(@company, @logo)
    end
  rescue ActiveRecord::RecordInvalid
    @metro_areas, @states = setup_locations_for(@company)
    render :action => 'edit'
  end
  
  def upload_company_logo
    @logo       = Logo.new(params[:logo])
    return unless request.put?
    
    @logo.company = @company
    if @logo.save
      @company.logo = @logo
      @company.save
      # redirect_to crop_profile_photo_user_path(@company)    # TODO
      redirect_to company_path(@company)
    end

    redirect_to company_path(@company)
  end

  def signup_completed
    @company = Company.find(params[:id])
    redirect_to home_path and return unless @company
    render :action => 'signup_completed', :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def activity
    @activities = Activity.about(resource).recent.paginate(paging_params.merge(:per_page => 25))
  end

  # TODO: refactor post_controller index to handle company parent objectm
  # TODO: This is broken at the routing level as well
  def posts
    @company = Company.find(params[:id])
    @category = Category.find_by_name(params[:category_name]) if params[:category_name]
    cond = Caboose::EZ::Condition.new
    if @category
      cond.append ['category_id = ?', @category.id]
    end

    @posts = @company.posts.recent.scoped(:conditions => cond.to_sql).paginate(paging_params)

    # @is_current_company = @company.eql?(current_company)

    @popular_posts = @company.posts.find(:all, :limit => 10, :order => "view_count DESC")

    @rss_title = "#{AppConfig.community_name}: #{@company.name}'s posts"
    @rss_url = posts_company_path(@company, :format => :rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss do
        render_rss_feed_for(@posts,
                            { :feed => {:title => @rss_title, :link => @rss_url },
                              :item => {:title => :title,
                                        :description => :post,
                                        :link => Proc.new {|post| post_path(post)},
                                        :pub_date => :published_at} })
      end
    end
  end

  def representative_comments
    @comments = @company.representative_comments.recent.find(:all, :page => {:size => 25, :current => params[:page]})  # TODO: will paginate
    @title = @company.name
    @back_url = company_path(@company)
    
    respond_to do |format|
      format.html do
        render :action => 'post_comments' and return
      end
      format.rss do
        @rss_title = "#{AppConfig.community_name}: #{@commentable.class.to_s.underscore.capitalize} Comments - #{@title}"
        @rss_url = comment_rss_link
        render_comments_rss_feed_for(@comments, @title) and return
      end
    end
  end

  def post_comments
    @comments = @company.post_comments.recent.find(:all, :page => {:size => 25, :current => params[:page]})  # TODO: will paginate
    @title = @company.name
    @back_url = company_path(@company)

    respond_to do |format|
      format.html do
        render :action => 'post_comments' and return
      end
      format.rss do
        @rss_title = "#{AppConfig.community_name}: #{@commentable.class.to_s.underscore.capitalize} Comments - #{@title}"
        @rss_url = comment_rss_link
        render_comments_rss_feed_for(@comments, @title) and return
      end
    end
  end

  protected

   def collection
     @companies ||= end_of_association_chain.recent.with(:metro_area, :logo).paginate(paging_params)
   end

  def admin_or_company_admin_required
    company = Company.find(params[:id])
    company && current_user && (current_user.admin? || company.admin?(current_user)) ? true : access_denied
  end

  def admin_or_company_representative_required
    current_user.admin? or @company.representative?(current_user) ? true : access_denied
  end

  def setup_metro_areas_for_cloud
    @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "companies_count > 0", :order => "companies_count DESC", :limit => 100)
    @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  end

  def setup_locations_for(company)
    metro_areas = states = []

    states = company.country.states if company.country

    metro_areas = company.state.metro_areas.all(:order => "name") if company.state

    return metro_areas, states
  end

  def get_additional_companies_page_data
    @sidebar_right = true
    @popular_posts = Post.find_popular(:limit => 5, :since => 5.days)
    @active_users = User.active.with(:photos).find_by_activity({:limit => 5, :require_avatar => false})
  end
end

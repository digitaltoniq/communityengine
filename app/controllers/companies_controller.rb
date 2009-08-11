require "RMagick"

class CompaniesController < BaseController
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit, :welcome_about])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  before_filter :admin_required, :only => [:new, :destroy]

  before_filter :admin_or_company_admin_required, :only => [:edit, :update, :change_company_logo, :upload_company_logo,
                                              #:welcome_photo, :welcome_about, :welcome_invite, :deactivate,
                                              # :crop_profile_photo
                                              ]

  def index
    # cond, @search, @metro_areas, @states = Company.paginated_users_conditions_with_search(params)  # TODO discuss apprach

    @companies = Company.recent.find(:all,
      # :conditions => cond.to_sql,
      :include => [:tags],
      :page => {:current => params[:page], :size => 20}
      )

    @tags = Company.tag_counts :limit => 10

    # setup_metro_areas_for_cloud  # TODO: discuss -- why have sidebar here?
  end

  def dashboard
    @company = Company.find(params[:id])
    #@network_activity = @company.network_activity
    #@recommended_posts = @company.recommended_posts
  end
  
  def show
    @company = Company.find(params[:id])

    #@friend_count               = @company.accepted_friendships.count
    #@accepted_friendships       = @company.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    #@pending_friendships_count  = @company.pending_friendships.count()
    #
    @post_comments       = @company.post_comments.find(:all, :limit => 10, :order => 'created_at DESC')
    #@photo_comments = Comment.find_photo_comments_for(@user)
    #@users_comments = Comment.find_comments_by_user(@user, :limit => 5)
    #

    @recent_posts   = @company.posts.find(:all, :limit => 2, :order => "published_at DESC")

    #@clippings      = @user.clippings.find(:all, :limit => 5)
    #@photos         = @user.photos.find(:all, :limit => 5)
    #@comment        = Comment.new(params[:comment])
    #
    #@my_activity = Activity.recent.by_users([@user.id]).find(:all, :limit => 10)
    #
    #update_view_count(@user) unless current_user && current_user.eql?(@user)

  end
  
  def new
    @company         = Company.new(params[:company])
    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode    
  end

  def create
    @company = Company.new(params[:company])

   if @company.save
     flash[:notice] = :company_signup_thanks.l_with_args(:email => @user.email)
     run_later {UserNotifier.deliver_signup_notification(@user)}
     # redirect_to signup_completed_company_path(@company)
     redirect_to company_path(@company)
    else
      render :action => 'new'
    end
  end
    
  def edit
    @company = Company.find(params[:id])
    @metro_areas, @states = setup_locations_for(@company)
    @logo = Logo.new
  end
  
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
  
  def destroy
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

  # TODO: refactor post_controller index to handle company
  def posts
    @company = Company.find(params[:id])
    @category = Category.find_by_name(params[:category_name]) if params[:category_name]
    cond = Caboose::EZ::Condition.new
    if @category
      cond.append ['category_id = ?', @category.id]
    end

    @posts = @company.posts.recent.find :all, :conditions => cond.to_sql, :page => {:size => 10, :current => params[:page]}

    # @is_current_company = @company.eql?(current_company)

    @popular_posts = @company.posts.find(:all, :limit => 10, :order => "view_count DESC")

    @rss_title = "#{AppConfig.community_name}: #{@company.name}'s posts"
    @rss_url = company_posts_path(@company, :format => :rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss do
        render_rss_feed_for(@posts,
                            { :feed => {:title => @rss_title, :link => url_for(:controller => 'posts', :action => 'index', :company_id => @company) },
                              :item => {:title => :title,
                                        :description => :post,
                                        :link => Proc.new {|post| company_post_url(post.company, post)},
                                        :pub_date => :published_at} })
      end
    end
  end

  def post_comments
    @company = Company.find(params[:id])
    @comments = @company.post_comments.recent.find(:all, :page => {:size => 10, :current => params[:page]})  # TODO: will paginate
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
  
    def admin_or_company_admin_required
      company = Company.find(params[:id]) 
      company && current_user && (current_user.admin? || company.company_admin?(current_user)) ? true : access_denied
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
end
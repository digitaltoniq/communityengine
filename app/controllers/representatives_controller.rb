class RepresentativesController < BaseController
  #before_filter :login_required, :except => [:accepted, :index]
  #before_filter :find_user, :only => [:accepted, :pending, :denied]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  include Viewable
  cache_sweeper :taggable_sweeper, :only => [:activate, :update, :destroy]

  if AppConfig.closed_beta_mode  # TODO: a mode for new representive by invite only
    skip_before_filter :beta_login_required, :only => [:new, :create, :activate]
    before_filter :require_invitation, :only => [:new, :create]

    def require_invitation
      redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
      redirect_to home_path and return false unless User.find(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
    end
  end

  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit, :welcome_about])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  # Filters TODO: remove methods not relevant to Representative, add others
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about,
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate,
                                          :crop_profile_photo, :upload_profile_photo]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics, :deactivate,
                                      :crop_profile_photo, :upload_profile_photo ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :deactivate,
                                                :crop_profile_photo, :upload_profile_photo]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_filter :admin_or_current_user_required, :only => [:statistics]

  def index
    @body_class = 'representives-browser'

    @company = Company.find(params[:company_id])
    @representative_count = @company.representatives.count
    @representatives = @company.representatives.find :all, :page => {:current => params[:page], :size => 12, :count => @representative_count }
   
    respond_to do |format|
      format.html
      format.xml { render :action => 'index.rxml', :layout => false}
    end
  end

  def show
    @representative = Representative.find(params[:representative_id] || params[:id])

    # TODO: temp use representative    
    @user = @representative.user

    @friend_count               = @user.accepted_friendships.count
    @accepted_friendships       = @user.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    @pending_friendships_count  = @user.pending_friendships.count()

    @comments       = @user.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    @photo_comments = Comment.find_photo_comments_for(@user)
    @users_comments = Comment.find_comments_by_user(@user, :limit => 5)

    @recent_posts   = @user.posts.find(:all, :limit => 2, :order => "published_at DESC")
    @clippings      = @user.clippings.find(:all, :limit => 5)
    @photos         = @user.photos.find(:all, :limit => 5)
    @comment        = Comment.new(params[:comment])

    @my_activity = Activity.recent.by_users([@user.id]).find(:all, :limit => 10)

    # TODO update_view_count(@user) unless current_user && current_user.eql?(@user)
  end


  def new
    @representative = Representative.new
    @representative.company = Company.find(params[:company_id])
    @representative.user = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id = params[:id]
    @inviter_code = params[:code]

    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode
  end

  def create
    user = User.new # ( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    # params[:representative][:user] = user
    @representative = Representative.new(params[:representative])
    # @representative.user = user
    @representative.company = Company.find(params[:company_id])
    # @representative.attributes = params[:representative]
    # @representative = Representative.new(params[:representative])
    # @representative.company = Company.find(params[:company_id])
    @representative.representative_role = RepresentativeRole[:representative]
    @representative.user.role = Role[:member]

    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@representative)) && @representative.save
      # create_friendship_with_inviter(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @representative.email)
      redirect_to signup_completed_user_path(@representative.user) # TODO: need representative signup completed?
      run_later {UserNotifier.deliver_signup_notification(@representative.user)}
    else
      render :action => 'new'
    end
  end

  def edit
    @representative = Representative.find(params[:representative_id] || params[:id])
    # TODO @metro_areas, @states = setup_locations_for(@representative.user)
    # @skills               = Skill.find(:all)
    # @offering             = Offering.new
    @avatar = Photo.new
  end

  def update
    @representative = Representative.find(params[:representative_id] || params[:id])
    @representative.attributes = params[:representative]
    # TODO @metro_areas, @states = setup_locations_for(@user)

    unless params[:metro_area_id].blank?
      @representative.metro_area  = MetroArea.find(params[:metro_area_id])
      @representative.state       = (@representative.metro_area && @representative.metro_area.state) ? @representative.metro_area.state : nil
      @representative.country     = @representative.metro_area.country if (@representative.metro_area && @representative.metro_area.country)
    else
      @representative.metro_area = @representative.state = @representative.country = nil
    end

    @avatar       = Photo.new(params[:avatar])
    @avatar.user  = @representative.user

    @representative.avatar  = @avatar if @avatar.save

    @representative.tag_list = params[:tag_list] || ''

    if @representative.save!
      @representative.track_activity(:updated_profile) # TODO: think about acitivity tracking across representative and user

      flash[:notice] = :your_changes_were_saved.l
      unless params[:welcome]
        redirect_to company_representative_path(@representative.company, @representative)
      else
        redirect_to :action => "welcome_#{params[:welcome]}", :id => @representative  # TODO
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

   def edit_account
    @user = current_user
    @is_current_user  = true
    respond_to do |format|
      format.html { render :template => 'users/edit_account'  }
    end    
  end

  def destroy
    unless @user.admin? || @user.featured_writer?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end  

end
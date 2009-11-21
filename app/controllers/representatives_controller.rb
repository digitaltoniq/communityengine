class RepresentativesController < BaseController

  # Trying to clean up RESTfully
  inherit_resources
  actions :show
  respond_to :html

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
    :only => [])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [])

  # Filters TODO: remove methods not relevant to Representative, add others
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about,
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate,
                                          :crop_profile_photo, :upload_profile_photo, :dashboard, :activity]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics, :deactivate,
                                      :crop_profile_photo, :upload_profile_photo, :dashboard, :activity ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :welcome_professional, :deactivate,
                                                :crop_profile_photo, :upload_profile_photo, :dashboard, :activity]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_filter :admin_or_current_user_required, :only => [:statistics]
  before_filter :ensure_valid_resource, :only => [:show, :dashboard, :activity]
  before_filter :set_title

  def activate
    redirect_to signup_path and return if params[:activation_code].blank?
    @user = User.find_by_activation_code(params[:activation_code])
    @representative = @user && Representative.find_by_user_id(@user.id)
    if @representative and @representative.activate
      self.current_user = @user
#      current_user.track_activity(:joined_the_site) # Tracked directly in representative
      redirect_to welcome_photo_company_representative_path(@representative.company, @representative)
      flash[:notice] = :thanks_for_activating_your_account.l
      RepresentativeNotifier.deliver_activation(@representative)
      return
    end
    flash[:error] = :account_activation_error.l_with_args(:email => AppConfig.support_email)
    redirect_to signup_path
  end

  # TODO
  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end
  
  def index
    @body_class = 'representives-browser'

    @company = Company.find(params[:company_id])
    @representative_count = @company.representatives.active.count
    @representatives = @company.representatives.active.with({:user => :avatar}, :company).paginate(paging_params)
   
    respond_to do |format|
      format.html
      format.xml { render :action => 'index.rxml', :layout => false}
    end
  end

  def show
    show! do
      @recent_comments       = Comment.ordered('created_at DESC').limited(10).find_all_by_user_id(@user.id)
      @recent_posts   = @user.posts.ordered("published_at DESC").limited(2)
      # TODO update_view_count(@user) unless current_user && current_user.eql?(@user)
    end
  end

  def dashboard
    redirect_to activity_company_representative_path(resource.company, resource)
  end

  def activity
    @company = resource.company
    @network_activity = Activity.about(resource).recent.paginate(paging_params.merge(:per_page => 25))
    respond_with(resource)
  end

  def new
    @representative = Representative.new
    @representative.company = Company.find(params[:company_id])
    redirect_to signup_path if @representative.company.blank?
    @representative.user = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id = params[:id]
    @inviter_code = params[:code]
    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode
  end

  def create
    @representative = Representative.new(params[:representative])
    @representative.company = Company.find(params[:company_id])
    @representative.birthday = DateTime.now.years_ago(18)

    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@representative)) && @representative.save
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @representative.email)
      redirect_to signup_completed_company_representative_path(@representative.company, @representative.id) 
      RepresentativeNotifier.deliver_signup_notification(@representative)
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

    if @representative.save!
      @representative.track_activity(:updated_profile) # TODO: think about acitivity tracking across representative and user

      flash[:notice] = :your_changes_were_saved.l
      if params[:welcome]
        redirect_to :action => "welcome_#{params[:welcome]}", :id => @representative
      elsif params[:registered]
        redirect_to dashboard_company_path(@representative.company)
      else
        redirect_to company_representative_path(@representative.company, @representative)
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
    @representative = Representative.find(params[:representative_id] || params[:id])
    if current_user.admin?
      @representative.destroy
      flash[:notice] = :the_representative_was_deleted.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  def signup_completed
    @representative = Representative.find(params[:representative_id] || params[:id])
    redirect_to home_path and return unless @representative
    render :action => 'signup_completed', :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def resend_activation
    @representative = Representative.find(params[:id])
    if @representative && !@representative.active?
      flash[:notice] = :activation_email_resent_message.l   
      RepresentativeNotifier.deliver_signup_notification(@representative)
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
      redirect_to signup_completed_company_representative_path(@representative.company, @representative)
    end
  end

  def welcome_photo
    @representative = Representative.find(params[:representative_id] || params[:id])
  end

  def welcome_about
    @representative = Representative.find(params[:representative_id] || params[:id])
    @metro_areas, @states = setup_locations_for(@user)
  end

  def welcome_invite
    @representative = Representative.find(params[:representative_id] || params[:id])
  end

  def welcome_professional
    @representative = Representative.find(params[:representative_id] || params[:id])
  end

  protected

    def set_title
      @page_title = case @action_name
        when 'show' then "#{resource}, #{resource.company} (#{resource.company.location})"
      end
    end

    # TODO: refactor with user_controller
    def setup_locations_for(user)
      metro_areas = states = []

      states = user.country.states if user.country

      metro_areas = user.state.metro_areas.ordered('name') if user.state

      return metro_areas, states
    end

  # Inherited resource overrides
  # NOTE: Will need to make better once nesting is supported?
  def resource
    @representative ||= Representative.for_user(@user)
  end
end

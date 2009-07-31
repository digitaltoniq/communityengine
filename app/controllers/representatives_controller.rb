class RepresentativesController < BaseController
  #before_filter :login_required, :except => [:accepted, :index]
  #before_filter :find_user, :only => [:accepted, :pending, :denied]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

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

end
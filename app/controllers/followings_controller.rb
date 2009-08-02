class FollowingsController < BaseController
  #before_filter :login_required, :except => [:accepted, :index]
  before_filter :find_user, :only => [:index, :companies, :posts]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  def index

    @company_followings_count = Following.company_followings_by_user(@user).count
    @post_followings_count    = Following.post_followings_by_user(@user).count

    @company_followings = Following.company_followings_by_user(@user).find :all, :limit => 4
    @post_followings    = Following.post_followings_by_user(@user).find :all, :limit => 4

    respond_to do |format|
      format.html
    end
  end

  def companies
    @company_followings_count = Following.company_followings_by_user(@user).count
    @company_followings = Following.company_followings_by_user(@user).find :all, :page => {:size => 12, :current => params[:page], :count => @company_followings_count}

    respond_to do |format|
      format.html
    end
  end

  def posts
    @post_followings_count = Following.post_followings_by_user(@user).count
    @post_followings = Following.post_followings_by_user(@user).find :all, :page => {:size => 12, :current => params[:page], :count => @followed_posts_count}

    respond_to do |format|
      format.html
    end
  end

end
class FollowingsController < BaseController
  # TODO
  #before_filter :login_required, :except => [:accepted, :index]
  before_filter :find_user, :only => [:index, :companies, :posts]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  def index
    @followings = Following.by_user(@user)
  end

  def companies
    @company_followings = Following.by_user(@user).for_companies.paginate(paging_params)
  end

  def posts
    @post_followings = Following.by_user(@user).for_posts.paginate(paging_params)
  end

  def create
    @user = User.find(params[:user_id])
    @followee = params[:followee_type] == "Company" ? Company.find(params[:followee_id]) : Post.find(params[:followee_id])
    @following = Following.new(:user => @user, :followed => @followee)
    respond_to do |format|
      if @following.save
        format.html do
          flash[:notice] = :now_following.l_with_args(:followee => display_text(@followee))
          redirect_to user_followings_path(@user)
        end
        format.js { render( :inline => :following.l ) }
      else
        flash.now[:error] = :following_could_not_be_created.l
        puts @following.errors.full_messages.join(", ")
        format.html { redirect_to user_followings_path(@user) }
        format.js { render( :inline => "Following request failed." ) }
      end
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @following = Followings.find(params[:id])
    @following.destroy
    respond_to do |format|
      format.html { redirect_to user_followings_path(@user) }
    end
  end


end
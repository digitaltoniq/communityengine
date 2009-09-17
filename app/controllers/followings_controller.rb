class FollowingsController < BaseController
  before_filter :login_required, :except => [:index, :companies, :posts]
  before_filter :find_user, :only => [:index, :companies, :posts, :create, :destroy]
  before_filter :require_current_user, :only => [:create, :destroy]

  def index
    @followings = Following.by(@user)
  end

  def companies
    @followings = Following.by(@user).for_companies.paginate(paging_params)
  end

  def posts
    @followings = Following.by(@user).for_posts.paginate(paging_params)
  end

  def create
    @followee = params[:followee_type].classify.constantize.find(params[:followee_id])
    @following = Following.follow!(@user, @followee)
    respond_to do |format|
      if !@following.new_record?
        format.html do
          flash[:notice] = :now_following.l_with_args(:followee => display_text(@followee))
          redirect_to user_followings_path(@user)
        end
        format.js { render(:partial => 'follow_link_inner', :locals => { :followee => @followee }) }
      else
        flash.now[:error] = :following_could_not_be_created.l
        puts @following.errors.full_messages.join(", ")
        format.html { redirect_to user_followings_path(@user) }
        format.js { render( :inline => "Following request failed." ) }
      end
    end
  end

  def destroy
    @following = Following.find(params[:id])
    @followee = @following.followee
    @following.destroy
    respond_to do |format|
      format.html { redirect_to user_followings_path(@user) }
      format.js { render(:partial => 'follow_link_inner', :locals => { :followee => @followee }) }
    end
  end
end

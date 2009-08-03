class FollowingsController < BaseController
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

end
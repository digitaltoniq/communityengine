class FollowersController < BaseController
  #before_filter :login_required, :except => [:accepted, :index]
  #before_filter :find_user, :only => [:accepted, :pending, :denied]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  def index
    @followed = Company.find(params[:company_id])    # TODO: determine followed type based on context
    @followings = Following.by_company(@followed).paginate(paging_params)

    #@following_count = @followed.followings.count
    #@followings = @followed.followings.find :all, :page => {:size => 12, :current => params[:page], :count => @followed_count}
  end

end
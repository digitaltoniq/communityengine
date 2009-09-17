class FollowersController < BaseController
  #before_filter :login_required, :except => [:accepted, :index]
  #before_filter :find_user, :only => [:accepted, :pending, :denied]
  #before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  def index
    @followee = Company.find(params[:company_id])    # TODO: determine followed type based on context, don't assume company
    @followings = @followee.followings.paginate(paging_params)
  end

end

class LikesController < BaseController

  before_filter :login_required

  def create
    current_user.likes!(likeable)
    respond_to do |format|
      format.html { redirect_to polymorphic_path(likeable) }
      format.js { render 'toggle' }
    end
  end

  def no_more
    current_user.dislikes!(likeable)
    respond_to do |format|
      format.html { redirect_to polymorphic_path(likeable) }
      format.js { render 'toggle' }
    end
  end

  private

  def likeable
    @likeable ||= params[:likeable_type].camelize.constantize.find(params[:likeable_id])
  end
end

#TODO: Use inherited resources
class RepresentativeInvitationsController < BaseController

  before_filter :login_required
  before_filter :find_company
  before_filter :company_rep_or_site_admin_required

  def index
    @invitations = @company.representative_invitations.by(current_user).ordered('created_at DESC').paginate(paging_params)
  end
  
  def new
    @representative_invitation = @company.representative_invitations.build(params[:representative_invitation])
  end

  def create
    @representative_invitation = @company.representative_invitations.
            build(params[:representative_invitation].merge({:user_id => current_user.id}))
    
    respond_to do |format|
      if @representative_invitation.save
        flash[:notice] = :representative_invitation_was_successfully_created.l
        format.html do
          redirect_to company_representative_invitations_path(@company)
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  private

  def find_company
    @company ||= Company.find(params[:company_id])
  end

  def company_rep_or_site_admin_required
    unless current_user.admin? or @company.representative?(current_user)
      flash[:error] = :cannot_invite_representatives_for_this_company.l(:company_name => @company)
      redirect_to company_path(@company)
    end
  end
  
end

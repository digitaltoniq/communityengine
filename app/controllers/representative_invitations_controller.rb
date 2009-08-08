class RepresentativeInvitationsController < BaseController
  before_filter :login_required

  def index
    @representative = Representative.find(params[:representative_id] || params[:id])
    @invitations = @representative.representative_invitations
  end
  
  def new
    @representative = Representative.find(params[:representative_id])
    @representative_invitation = RepresentativeInvitation.new(params[:representative_invitation]) 
  end

  def create
    @representative = Representative.find(params[:representative_id])
    @representative_invitation = RepresentativeInvitation.new(params[:representative_invitation])
    @representative_invitation.representative = @representative
    
    respond_to do |format|
      if @representative_invitation.save
        flash[:notice] = :representative_invitation_was_successfully_created.l
        format.html do
          unless params[:welcome]  # TODO: what's this about?
            redirect_to company_representative_path(@representative.company, @representative)
          else
            redirect_to welcome_complete_user_path(@representative.user)     # TODO: don't reference user       
          end
        end
      else
        format.html { render :action => "new" }
      end
    end
  end
  
end
class AdminController < BaseController

  before_filter :admin_required
  before_filter :set_manage_section
  
  def contests
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contests.to_xml }
    end    
  end

  def events
    @events = Event.find(:all, :order => 'start_time DESC', :page => {:current => params[:page]})
  end
  
  def messages
    @user = current_user
    @messages = Message.find(:all, :page => {:current => params[:page], :size => 50}, :order => 'created_at DESC')
  end
  
  def users
    cond = Caboose::EZ::Condition.new
    if params['login']    
      cond.login =~ "%#{params['login']}%"
    end
    if params['email']
      cond.email =~ "%#{params['email']}%"
    end        
    
    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
  end

  def dashboard
    @network_activity = Activity.recent.root.paginate(paging_params.merge(:per_page => 10))
  end

  def activity
    @network_activity = Activity.recent.root.paginate(paging_params.merge(:per_page => 25))
  end
  
  def comments
    @comments = Comment.ordered('created_at DESC').paginate(paging_params.merge(:per_page => 25))
  end

  def companies
    @companies = Company.ordered("created_at DESC").paginate(paging_params.merge(:per_page => 25))
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = :the_user_was_activated.l
    redirect_to :action => :users
  end
  
  def deactivate_user
    user = User.find(params[:id])
    user.deactivate
    flash[:notice] = "The user was deactivated".l
    redirect_to :action => :users
  end

  def set_manage_section
    @section = 'manage'
  end
  
end
class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_create(comment)
    expire_cache_for(comment)
  end
  
  # If our sweeper detects that a comment was updated call this
  def after_update(comment)
    expire_cache_for(comment)
  end
  
  # If our sweeper detects that a comment was deleted call this
  def after_destroy(comment)
    expire_cache_for(comment)
  end
          
  private
  def expire_cache_for(record)
    # Expire the footer content
    expire_action :controller => 'base', :action => 'footer_content'

    if record.commentable_type.eql?('Post')
      expire_action :controller => 'posts', :action => 'show', :id => record.commentable , :user_id => record.commentable.user
      expire_action :controller => 'posts', :action => 'show', :id => record.commentable , :company_id => Company.for_post(record).to_param
      ['index', 'popular', 'recent', 'most_discussed'].each do |action|
        expire_action :controller => 'posts', :action => action
      end
    end

  end
end
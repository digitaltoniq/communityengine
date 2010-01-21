class LikeSweeper < ActionController::Caching::Sweeper
  observe Like

  def after_create(like)
    expire_cache_for(like)
  end

  # If our sweeper detects that a like was updated call this
  def after_update(like)
    expire_cache_for(like)
  end

  # If our sweeper detects that a like was deleted call this
  def after_destroy(like)
    expire_cache_for(like)
  end

  private
  def expire_cache_for(record)

    if record.likeable_type.eql?('Comment') and record.likeable.commentable_type.eql?('Post')
      post = record.likeable.commentable
      expire_action :controller => 'posts', :action => 'show', :id => post.to_param , :user_id => post.user.to_param
      expire_action :controller => 'posts', :action => 'show', :id => post.to_param , :company_id => Company.for_post(post).to_param
    end

  end
end
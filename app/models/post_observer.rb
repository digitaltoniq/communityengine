class PostObserver < ActiveRecord::Observer

  def after_create(post)
    post.send_notifications
  end
end

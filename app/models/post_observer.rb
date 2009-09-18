class PostObserver < ActiveRecord::Observer

  def after_create(post)
    Company.register_activity(post)
  end
end

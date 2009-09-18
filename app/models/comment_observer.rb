class CommentObserver < ActiveRecord::Observer

  def after_create(comment)
    Company.register_activity(comment)
  end
end

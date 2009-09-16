module LikeableHelper

  def user_likes_path(likeable)
    likes_path(:likeable_type => likeable.class.to_s.downcase, :likeable_id => likeable.id)
  end

  def user_dislikes_path(likeable)
    no_more_likes_path(:likeable_type => likeable.class.to_s.downcase, :likeable_id => likeable.id)
  end
end

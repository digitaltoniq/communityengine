class UserObserver < ActiveRecord::Observer

  def after_create(user)
    UserNotifier.deliver_signup_notification(user) unless Representative.for_user(user)
  end

  def after_save(user)
    UserNotifier.deliver_activation(user) if user.recently_activated? and !Representative.for_user(user)
  end
end

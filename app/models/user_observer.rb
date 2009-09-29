class UserObserver < ActiveRecord::Observer

  def after_create(user)
    if !Representative.for_user(user)
      UserNotifier.deliver_signup_notification(user)
    end
  end

  def after_save(user)
    if !Representative.for_user(user)
      UserNotifier.deliver_activation(user) if user.recently_activated?
    end
  end
end

class UserObserver < ActiveRecord::Observer

#  # Now handled directly in UsersController#create to avoid double notifications
#  # on representative creation 
#  def after_create(user)
#    if !Representative.for_user(user)
#      UserNotifier.deliver_signup_notification(user)
#    end
#  end

  def after_save(user)
    if !Representative.for_user(user)
      UserNotifier.deliver_activation(user) if user.recently_activated?
    end
  end
end

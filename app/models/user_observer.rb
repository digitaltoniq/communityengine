class UserObserver < ActiveRecord::Observer

  # RWD: pull out of model lifecycle and put at controller level
  # Also: dup of user.after_create callbacks?
  #
  # def after_create(user)
  #   UserNotifier.deliver_signup_notification(user)
  # end
  # 
  # def after_save(user)
  #   UserNotifier.deliver_activation(user) if user.recently_activated?
  # end
end
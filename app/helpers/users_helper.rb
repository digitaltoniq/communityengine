module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end    
  
  def random_greeting(user)
    greetings = ['Hello', 'Hola', 'Hi ', 'Yo', 'Welcome back,', 'Greetings',
        'Wassup', 'Aloha', 'Halloo']
#    "#{greetings.sort_by {rand}.first} #{display_name(user)}!"
    "Hello #{user}"
  end

  def user_location(user, full = true)
    locatable = (rep = Representative.for_user(user)) ? rep : user
    full ? locatable.full_location : locatable.location
  end
end
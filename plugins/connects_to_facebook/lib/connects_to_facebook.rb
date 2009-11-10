module DT
  module ConnectsToFacebook

    def self.included(within)
      within.class_eval { extend ClassMethods }
    end

    module ClassMethods

      def connects_to_facebook
        extend SingletonMethods
        include InstanceMethods
        after_create :register_user_to_fb
      end
    end

    module SingletonMethods

      #find the user in the database, first by the facebook user id and if that fails through the email hash
      def find_by_fb_user(fb_user)
        find_by_fb_user_id(fb_user.uid) || find_by_email_hash(fb_user.email_hashes)
      end

      #Take the data returned from facebook and create a new user from it.
      #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
      #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
      def create_from_fb_connect(fb_user)
        returning(new(:fb_user_id => fb_user.uid.to_i, :first_name => fb_user.first_name, :last_name => fb_user.last_name, :email => fb_user.proxied_email)) do |facebooker|
          facebooker.activated_at = Time.now
          facebooker.save
          facebooker.register_user_to_fb
        end
      end

    end

    module InstanceMethods

      #We are going to connect this user object with a facebook id. But only ever one account.
      def link_fb_connect(fb_user_id)
        unless fb_user_id.nil?
          #check for existing account
          existing_fb_user = User.find_by_fb_user_id(fb_user_id)
          #unlink the existing account
          unless existing_fb_user.nil?
            existing_fb_user.fb_user_id = nil
            existing_fb_user.save
          end
          #link the new one
          self.fb_user_id = fb_user_id
          save
        end
      end

      #The Facebook registers user method is going to send the users email hash and our account id to Facebook
      #We need this so Facebook can find friends on our local application even if they have not connect through connect
      #We hen use the email hash in the database to later identify a user from Facebook with a local user
      def register_user_to_fb
        users = {:email => email, :account_id => id}
        Facebooker::User.register([users])
        self.email_hash = Facebooker::User.hash_email(email)
        save
      end
      
      def facebook_user?
        return !fb_user_id.nil? && fb_user_id > 0
      end
    end
  end
end
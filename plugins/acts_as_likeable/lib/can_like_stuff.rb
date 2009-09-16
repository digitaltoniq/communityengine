module DT
  module Can #:nodoc:
    module LikeStuff #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def can_like_stuff
          has_many :likes, :dependent => :delete_all
          include DT::Can::LikeStuff::InstanceMethods
          extend DT::Can::LikeStuff::SingletonMethods
        end
      end

      # This module contains class methods
      module SingletonMethods
      end

      # This module contains instance methods
      module InstanceMethods

        def likes?(likeable)
          like = like_for(likeable)
          like ? like.like? : false
        end

        def likes!(likeable)
          like = like_for(likeable)
          like ? like.update_attribute(:like, true) : likes.create(:likeable => likeable)
        end

        def dislikes!(likeable)
          like = like_for(likeable)
          like.destroy if like
        end

        private

        def like_for(likeable)
          likes.for(likeable).first
        end
      end
    end
  end
end

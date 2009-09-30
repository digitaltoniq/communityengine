module ActivityTracker # :nodoc:

  def self.included(base) # :nodoc:
    base.extend ActMethods
  end
  
  module ActMethods

    # Arguments: 
    #   <tt>:actor</tt> - the user model that owns this object. In most cases this will be :user. Required.
    #   <tt>:options</tt> - hash of options.  <tt>:about</tt>, <tt>:if</tt>
    #   * <tt>:about</tt> - the model that this activity is about (often the non-user owner of this item)
    #
    #
    # Options:
    #   <tt>:if</tt> - a Proc that determines if the activity should be tracked.
    #
    # Examples:
    #   acts_as_activity :user
    #   acts_as_activity :user, :about => proc { |c| Company.for_comment(c) }
    #   acts_as_activity :user, :if => Proc.new{|record| record.post.length > 100 } - will only track the activity if the length of the post is more than 100
    def acts_as_activity(actor, options = {})
      unless included_modules.include? InstanceMethods
        after_create do |record|
          unless options[:if].kind_of?(Proc) and not options[:if].call(record)
            record.create_activity_from_self 
          end
        end

        has_many :activities, :as => :item, :dependent => :destroy
        class_inheritable_accessor :activity_options
        include InstanceMethods
      end      
      self.activity_options = {:actor => actor, :about => options[:about]}
    end
    
    # This adds a helper method to the model which makes it easy to track actions that can't be associated with an object in the database.
    # Options:
    #   <tt>:actions</tt> - An array of actions that are accepted to be tracked.
    #
    # Examples: 
    #   tracks_unlinked_activities [:logged_in, :invited_friends] - class.track_activity(:logged_in)
    #
    def tracks_unlinked_activities(actions = [])
      unless included_modules.include? InstanceMethods
        class_inheritable_accessor :activity_options
        include InstanceMethods
      end
      self.activity_options = {:actions => actions}    
      after_destroy { |record| Activity.destroy_all(:actor_type => record.class.to_s, :actor_id => record.id) }
    end
        
  end

  module InstanceMethods

    def create_activity_from_self
      actor = activity_options[:actor] ? send(activity_options[:actor]) : nil
      about = case (about_opt = activity_options[:about]).class.to_s
        when 'Symbol' then send(about_opt)
        when 'Proc' then about_opt.call(self)
        else nil
      end 
      Activity.create(:item => self, :actor => actor, :about => about, :action => 'created')
    end

    def track_activity(action)
      if activity_options[:actions].include?(action)
        activity = Activity.new
        activity.action = action.to_s
        activity.actor = self
        activity.save!
      else
        raise "The action #{action} can't be tracked."
      end
    end    

    
  end


end

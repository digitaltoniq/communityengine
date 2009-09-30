class Activity < ActiveRecord::Base

  belongs_to :actor, :polymorphic => true # Who performed the activity
  belongs_to :item, :polymorphic => true  # The item that triggered the activity
  belongs_to :about, :polymorphic => true # What the activity is about (often the owner of the item)
  
  after_save :update_counter_on_actor

  named_scope :since, lambda { |time|
    {:conditions => ["activities.created_at > ?", time] }
  }
  named_scope :before, lambda {|time|
    {:conditions => ["activities.created_at < ?", time] }    
  }
  named_scope :recent, :order => "activities.created_at DESC"

  named_scope :by, lambda {|actor|
    {:conditions => { :actor_type => actor.class.to_s, :actor_id => actor.id } }
  }
  named_scope :about, lambda { |about|
    { :conditions => { :about_type => about.class.to_s, :about_id => about.id } }
  }
  named_scope :about_type, lambda {|type|
    {:conditions => { :about_type => type.to_s } }
  }

  def update_counter_on_actor
    if actor && actor.class.column_names.include?('activities_count')
      actor.update_attribute(:activities_count, Activity.by(actor).count )
    end
  end
  
  def can_be_deleted_by?(actor)
    return false if actor.nil?
    actor.admin? || actor.moderator? || self.actor == actor
  end
    
end

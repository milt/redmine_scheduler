# Patches Redmine's Users dynamically.  Adds a relationship User +has_and_belongs_to_many+ Skill. 
module TrackerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :fdshift_track, :conditions => { :name => "Front Desk Shift" }
      named_scope :lcshift_track, :conditions => { :name => "Lab Coach Shift" }
      named_scope :task_track, :conditions => { :name => "Task" }
      named_scope :goal_track, :conditions => { :name => "Training Goal" }
      named_scope :event_track, :conditions => { :name => "Event" }
      
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end


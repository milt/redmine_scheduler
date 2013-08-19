# Patches Redmine's Trackers
module TrackerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      scope :fdshift_track, :conditions => { :name => "Front Desk Shift" }
      scope :lcshift_track, :conditions => { :name => "Lab Coach Shift" }
      scope :task_track, :conditions => { :name => "Task" }
      scope :goal_track, :conditions => { :name => "Training Goal" }
      scope :event_track, :conditions => { :name => "Event" }
      scope :repair_track, :conditions => { :name => "Equipment Problem" }
      scope :poster_track, :conditions => { :name => "Poster Print" }

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end


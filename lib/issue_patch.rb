require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship 
# Issue +has_many+ to Timeslot
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :timeslots, :dependent => :destroy # Establish a relationship with timeslots, destroy timeslot if issue destroyed
      safe_attributes 'start_time',
        'end_time'
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)

require_dependency 'time_entry'

# Patches Redmine's Users dynamically.  Adds a relationship User +has_and_belongs_to_many+ Skill. 
module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :foruser, lambda {|u| { :conditions => { :user_id => u.id } } }

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

# Add module to User
TimeEntry.send(:include, TimeEntryPatch)

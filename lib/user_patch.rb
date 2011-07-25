require_dependency 'user'

# Patches Redmine's Users dynamically.  Adds a relationship 
# User +has_and_belongs_to_many+ to Skill

module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :skills
      
    end

  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    #def deliverable_subject
    #  unless self.deliverable.nil?
    #    return self.deliverable.subject
    #  end
    #end
  end    
end

# Add module to User
User.send(:include, UserPatch)

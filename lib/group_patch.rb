# Patches Redmine's Groups dynamically.  Adds a relationships to support an "owner" for a given group.
module GroupPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :manager, :class_name => "User"
      named_scope :stustaff, lambda { { :conditions => { :lastname => "Stustaff"} } }

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

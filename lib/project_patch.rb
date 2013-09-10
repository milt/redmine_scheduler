# Patches Redmine's Projects
module ProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      scope :repair_project, :conditions => { :name => "Repair & Replace" }
      scope :poster_project, :conditions => { :name => "Poster Printing" }
      safe_attributes 'suppress_email'
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end


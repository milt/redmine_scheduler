# Patches Redmine's Users dynamically.  Adds a relationship User +has_and_belongs_to_many+ Skill. 
module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :skills
      belongs_to :wage
      has_many :workgroups, :class_name => "Group",
        :foreign_key => "manager_id"
      has_many :time_entries

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end


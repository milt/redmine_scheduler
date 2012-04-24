# Patches Redmine's Users dynamically.  Adds a relationship User +has_and_belongs_to_many+ Skill. 
module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :timesheet
      named_scope :foruser, lambda {|u| { :conditions => { :user_id => u.id } } }
      named_scope :after, lambda {|d| { :conditions => ["spent_on >= ?", d] } }
      named_scope :before, lambda {|d| { :conditions => ["spent_on <= ?", d] } }
      named_scope :ondate, lambda {|d| { :conditions => ["spent_on == ?", d] } }
      named_scope :sort_by_date, :order => "spent_on ASC"

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

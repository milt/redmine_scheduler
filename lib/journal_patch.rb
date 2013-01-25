# Patches Redmine's journals for named scope
module JournalPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :last_day, lambda { { :conditions => ["created_at >= ?", DateTime.now - 24.hours] } }
      named_scope :from_issue, lambda { |i| { :conditions => { :type => 'IssueJournal', :journaled_id => i[:id] } } }
      named_scope :from_time_entry, lambda { |t| { :conditions => { :type => 'TimeEntryJournal', :journaled_id => t[:id] } } }
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end


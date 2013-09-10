# Patches Redmine's journals for named scope
module JournalPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      scope :last_day, lambda { { :conditions => ["created_on >= ?", DateTime.now - 24.hours] } }
      scope :from_issue, lambda { |i| { :conditions => { :journalized_type => 'Issue', :journalized_id => i[:id] } } }
      scope :from_time_entry, lambda { |t| { :conditions => { :journalized_type => 'TimeEntry', :journalized_id => t[:id] } } }
      #scope :not_initial, lambda { { :conditions => ["version > ?", 1]} }
      scope :order_for_display, lambda { {:order => 'created_on ASC'}}
    end

  end

  module ClassMethods

  end

  module InstanceMethods
    def renderable_details #this gives warnings, I don't care!
      self.details.reject {|d| render_detail(d,false) == nil }
    end

  end
end


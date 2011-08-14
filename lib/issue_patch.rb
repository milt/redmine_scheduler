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
      safe_attributes 'start_time', 'end_time'
      
      def timelist
        #((Time.local(0,1,1,0)..Time.local(0,1,1,23,59)).select {|a| (a.min.eql?(0) | a.min.eql?(30)) & a.sec.eql?(0)}).collect {|b| b.strftime("%I:%M %P")}        
        ((Time.local(0,1,1,0)..Time.local(0,1,1,23,59)).select {|a| (a.min.eql?(0) | a.min.eql?(30)) & a.sec.eql?(0)}).collect {|t| [t.strftime("%I:%M %P"), t]}
      end
            
      def start_time=(time)
          write_attribute :start_time, (time)
      end
      
      def end_time=(time)
          write_attribute :end_time, (time)
      end
      
    end

  end

  module ClassMethods

  end

  module InstanceMethods
      def shift_duration
        ((start_time && end_time) ? end_time - start_time : 0)/60/60
      end
      
      def shift_start_index
        (start_time.hour * 2) + (start_time.min/30)
      end
      
      def shift_end_index
        (end_time.hour * 2) + (end_time.min/30)
      end
  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)

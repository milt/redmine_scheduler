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
      alias_method_chain :validate, :shift_times      

    end

  end

  module ClassMethods

  end

  module InstanceMethods
    def timelist_lc
      ((Time.local(0,1,1,0)..Time.local(0,1,1,23,59)).select {|a| (a.min.eql?(15) | a.min.eql?(45)) & a.sec.eql?(0)}).collect {|t| [t.strftime("%I:%M %P"), t]}
    end
    
    def timelist_fd
      ((Time.local(0,1,1,0)..Time.local(0,1,1,23,59)).select {|a| (a.min.eql?(15) | a.min.eql?(45)) & a.sec.eql?(0)}).collect {|t| [t.strftime("%I:%M %P"), t]}
    end
          
    def start_time=(time)
        write_attribute :start_time, (time)
    end
    
    def end_time=(time)
        write_attribute :end_time, (time)
    end
    
    def shift_duration
      ((start_time && end_time) ? end_time - start_time : 0)/60/60
    end
    
    def shift_start_index
      (start_time.hour * 2) + (start_time.min/30)
    end
    
    def shift_end_index
      (end_time.hour * 2) + (end_time.min/30)
    end

    def shift_duration_index
      shift_end_index - shift_start_index
    end
    
    def validate_with_shift_times
      if self.end_time and self.start_time and self.end_time < self.start_time
        errors.add :due_date, :greater_than_start_date
      end
    end
    
    def open_slots?
      if ((self.timeslots.detect {|t| t.open? }).present?) && (self.start_time > DateTime.now)
        return true
      else
        return false
      end
    end
    
    def open_slots
      self.timeslots.select {|t| t.open?}
    end
    
    def booked_slots
      self.timeslots.select {|t| t.booked?}
    end
    
    def is_labcoach_shift?
      unless self.tracker.name == 'Lab Coach Shift'
        return false
      end
        return true
    end
    def is_frontdesk_shift?
      unless self.tracker.name == 'Front Desk Shift'
        return false
      end
        return true
    end
    
    def is_shift?
      if self.is_labcoach_shift? || self.is_frontdesk_shift?
        return true
      else
        return false
      end
    end
    
    def create_timeslots
      self.shift_duration_index.times {|i| self.timeslots << Timeslot.create(:slot_time => i)}
    end
    
    def recreate_timeslots
      #find timeslots on current shift with bookings, destroy others.
      cache = []
      self.timeslots.each do |slot|
        if slot.booked?
          cache << slot
        else
          slot.destroy
        end
      end
      
      #for each slot_time index, check to see if there is a matching time among the cached timeslots. If none, make a new slot. If there is one, change it's slot time to the proper index and remove from the cache.
      self.shift_duration_index.times do |i|
        match = cache.detect {|s| s.booking.apt_time == (self.start_time + (i * 30).minutes)}
        if match.nil?
          self.timeslots << Timeslot.create(:slot_time => i)
        else
          cache = cache.reject {|s| s.id == match.id}
          match.slot_time = i
          match.save
        end
      end
      
      #destroy the remaining slots, orphaning their bookings. Could put better stuff here later.
      cache.each do |slot|
        slot.destroy
      end
      
    end
        
  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)

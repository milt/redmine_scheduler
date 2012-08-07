# Patches Redmine's Issue model dynamically.  Adds a relationship Issue +has_many+ to Timeslot. this is a module, hence it has a slightly different order.
module IssuePatch
  def self.included(base) # :nodoc: add the indicated methods to Issue. not sure what :nodoc: did but it is off now
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :timeslots, :dependent => :destroy # Establish a relationship with timeslots, destroy timeslot if issue destroyed
      has_many :bookings, :through => :timeslots
      safe_attributes 'start_time', 'end_time' #since our migration adds start_time and end_time to issues for use as shifts, we need to mark these as safe for editing.
      alias_method_chain :validate, :shift_times #patches validation to check for sane shift times. see validate_with_shift_times below
      named_scope :today, lambda { { :conditions => { :start_date => Date.today } } }
      named_scope :fdshift, lambda { { :conditions => { :tracker_id => Tracker.fdshift_track.first.id } } }
      named_scope :lcshift, lambda { { :conditions => { :tracker_id => Tracker.lcshift_track.first.id } } }
      named_scope :tasks, lambda { { :conditions => { :tracker_id => Tracker.task_track.first.id } } }
      named_scope :goals, lambda { { :conditions => { :tracker_id => Tracker.goal_track.first.id } } }
      named_scope :foruser, lambda {|u| { :conditions => { :assigned_to_id => u.id } } }
      named_scope :events, lambda { { :conditions => { :tracker_id => Tracker.event_track.first.id } } }
      named_scope :by_start_date, lambda {|d| { :conditions => { :start_date => d } } }
      named_scope :until_date, lambda {|d| { :conditions => ["start_date <= ?", d] } }
      named_scope :from_date, lambda {|d| { :conditions => ["start_date >= ?", d] } }
      after_create :create_timeslots, :if => :is_labcoach_shift?
      after_update :recreate_timeslots, :if => :is_labcoach_shift?

    end

  end

  module ClassMethods #we don't currently have any class methods for Issues

    def time_list
      list = []
      t = Time.local(0,1,1,0,15)
      for h in 0..49
        list << [ (t + h*30.minutes).strftime("%I:%M %p"), h ]
      end
      return list
    end

  end

  module InstanceMethods #methods to run on shifts. as is, we can run them on all issues which is not good.
    def timelist_lc #generate a list of valid times for lab coach shifts to start. This shouldn't be here, but this is where it worked. clean up
      timelist = []
      t = Time.local(0,1,1,0,15)
      47.times do
        timelist = timelist << t.strftime("%I:%M %p")
        t = t + 30.minutes
      end
      return timelist
    end
    
    def timelist_fd #generate a list of valid times for front desk coach shifts to start. This shouldn't be here, but this is where it worked. clean up
      timelist = []
      t = Time.local(0,1,1,0,15)
      47.times do
        timelist = timelist << t.strftime("%I:%M %p")
        t = t + 30.minutes
      end
      return timelist
    end
          
    def start_time=(time) #this method and the one below are used to write to the fields with the older write_attribute method. this is bad, and maybe is not necessary, need to look at it
        write_attribute :start_time, (time)
    end
    
    def end_time=(time)
        write_attribute :end_time, (time)
    end
    
    def shift_duration #get the duration of a shift
      ((start_time && end_time) ? end_time - start_time : 0)/60/60
    end
    
    def shift_duration_index #duration in 1/2 hr increments
      (shift_duration/0.5).to_i
    end

    #TODO: these two indexes don't work right sometimes. They are now only used for setting the selected value. Fix or rewrite
    def shift_start_index #integer expressing shift start time as one of 48 1/2 hr increments in a day
      (start_time.hour * 2) + (start_time.min/30)
    end
    
    def shift_end_index #same for end
      (end_time.hour * 2) + (end_time.min/30)
    end
    
    def validate_with_shift_times # see alias_method_chain above
      if self.end_time and self.start_time and self.end_time < self.start_time
        errors.add :due_date, :greater_than_start_date
      end
    end
    
    def open_slots? #does this shift have open timeslots?
      if ((self.timeslots.detect {|t| t.open? }).present?) && (self.start_time > DateTime.now)
        return true
      else
        return false
      end
    end
    
    def open_slots #list open slots on this shift
      self.timeslots.select {|t| t.open?}
    end
    
    def booked_slots #list booked slots on this shift
      self.timeslots.select {|t| t.booked?}
    end
    
    def is_labcoach_shift? #is this an LC shift?
      unless self.tracker.name == 'Lab Coach Shift'
        return false
      end
        return true
    end
    def is_frontdesk_shift? #is this a FD shift?
      unless self.tracker.name == 'Front Desk Shift'
        return false
      end
        return true
    end
    
    def is_shift? #is this a shift at all?
      if self.is_labcoach_shift? || self.is_frontdesk_shift?
        return true
      else
        return false
      end
    end
    
    def create_timeslots #generate timeslots for this shift
      self.shift_duration_index.times {|i| self.timeslots << Timeslot.create(:slot_time => i)}
    end
    
    def recreate_timeslots #when a shift changes time dimensions and is saved (see hook), any timeslots associated with it must be checked and updated. Right now, only timeslots with bookings are kept, otherwise new ones are made
      cache = [] #make an empty array to cache timeslots we are keeping
      self.timeslots.each do |slot| #for each timeslot on this shift,
        if slot.booked? # if the timeslot has a booking associated, hold on to it
          cache << slot
        else
          slot.destroy # if not, destroy it
        end
      end
      
      #for each slot_time index, check to see if there is a matching time among the cached (booked) timeslots. If none, make a new slot. If there is one, change it's slot time to the proper index and remove from the cache.
      self.shift_duration_index.times do |i| #for each 30 min interval in the updated and saved shift
        match = cache.detect {|s| s.booking.apt_time == (self.start_time + (i * 30).minutes)} #detect whether any slots in the cache fall within the new shift times
        if match.nil? #if none match, make a new slot
          self.timeslots << Timeslot.create(:slot_time => i)
        else #if there is a match
          cache = cache.reject {|s| s.id == match.id} #remove it from the cache
          match.slot_time = i #set its slot time to the current index
          match.save #save the timeslot, preserving the booking at the correct apt_time
        end
      end
      
      #destroy the remaining slots in the cache, orphaning their bookings. Put better stuff here later, but for now it shows up in the Manage controller.
      cache.each do |slot|
        slot.destroy
      end
      
    end
        
  end
end


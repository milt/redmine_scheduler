# Patches Redmine's Issue model dynamically.  Adds a relationship Issue +has_many+ to Timeslot. this is a module, hence it has a slightly different order.
module IssuePatch
  def self.included(base) # :nodoc: add the indicated methods to Issue. not sure what :nodoc: did but it is off now
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :timeslots, :dependent => :destroy # Establish a relationship with timeslots, destroy timeslot if issue destroyed
      has_many :bookings, :through => :timeslots, :dependent => :destroy
      has_one :repair, :dependent => :nullify
      safe_attributes 'start_time', 'end_time' #since our migration adds start_time and end_time to issues for use as shifts, we need to mark these as safe for editing.
      #alias_method_chain :validate, :shift_times #patches validation to check for sane shift times. see validate_with_shift_times below
      validate :validate_with_shift_times
      scope :today, lambda { { :conditions => { :start_date => Date.today } } }
      scope :fdshift, lambda { { :conditions => { :tracker_id => Tracker.fdshift_track.first.id } } }
      scope :lcshift, lambda { { :conditions => { :tracker_id => Tracker.lcshift_track.first.id } } }
      scope :repairs, lambda { { :conditions => { :tracker_id => Tracker.repair_track.first.id } } }
      scope :unassigned, lambda { { :conditions => { :assigned_to_id => nil } } }
      #need to add a scope for development tracker?
      scope :tasks, lambda { { :conditions => { :tracker_id => Tracker.task_track.first.id } } }
      scope :goals, lambda { { :conditions => { :tracker_id => Tracker.goal_track.first.id } } }
      scope :foruser, lambda {|u| { :conditions => { :assigned_to_id => u.id } } }
      scope :for_author, lambda {|u| { :conditions => { :author_id => u.id } } }
      scope :events, lambda { { :conditions => { :tracker_id => Tracker.event_track.first.id } } }
      scope :by_start_date, lambda {|d| { :conditions => ["start_date = ?", d] } }
      scope :from_date, lambda {|d| { :conditions => ["start_date >= ?", d] } }
      scope :until_date, lambda {|d| { :conditions => ["start_date <= ?", d] } }
      scope :from_start_time, lambda {|dt| {conditions => ["start_time >= ?", dt] } }
      scope :until_start_time, lambda {|dt| {conditions => ["start_time <= ?", dt] } }
      scope :omit_user, lambda {|u| { :conditions => ["assigned_to_id != ?", u.id] } } # not used
      scope :omit_user_id, lambda {|u| { :conditions => ["assigned_to_id != ?", u] } }

      scope :updated_in_last_day, lambda { { :conditions => ["updated_on >= ?", DateTime.now - 24.hours] } }
      scope :created_in_last_day, lambda { { :conditions => ["created_on >= ?", DateTime.now - 24.hours] } }

      after_create :create_timeslots, :if => :is_labcoach_shift?
      after_update :recreate_timeslots, :if => (:is_labcoach_shift? && :times_changed?)
      scope :feedback, lambda { { :conditions => ["status_id = 4"] } }
      after_destroy :cancel_bookings
      belongs_to :user, foreign_key: 'assigned_to_id'

      def self.with_skills(*skills)
        joins(:assigned_to).merge(User.with_skills(*skills))
      end
    end

  end

  module ClassMethods

    def omit_user_ids(ids)
      c = self
      ids.each do |id|
        c = c.send :omit_user_id, id
      end
      return c
    end

    def time_list #list of possible clock times a shift can start.
      list = []
      t = Time.local(0,1,1,0,15)

      # indices = *(0..49)
      # indices.rotate!(offset*2)

      for h in 0..49  
        list << [ (t + h*30.minutes).strftime("%I:%M:%S %p"), h ]
      end
      return list
    end

  end

  module InstanceMethods #methods to run on shifts mostly

    def skills #used to filter by skills
      self.assigned_to.skills
    end
          
    # def start_time=(time) #this method and the one below are used to write to the fields with the older write_attribute method. this is bad, and maybe is not necessary, need to look at it
    #     write_attribute :start_time, (time)
    # end
    
    # def end_time=(time)
    #     write_attribute :end_time, (time)
    # end
    
    def shift_duration #get the duration of a shift
      ((self.start_time && self.end_time) ? self.end_time - self.start_time : 0)/60/60
    end
    
    def shift_duration_index #duration in 1/2 hr increments
      (self.shift_duration/0.5).to_i
    end

    #TODO: these two indexes don't work right sometimes. They are now only used for setting the selected value. Fix or rewrite
    def shift_start_index #integer expressing shift start time as one of 48 1/2 hr increments in a day
      (start_time.hour * 2) + (start_time.min/30)
    end
    
    def shift_end_index #same for end
      index = (end_time.hour * 2) + (end_time.min/30)
      index += 48 if index <= shift_start_index
      return index
    end

    def set_times_from_index(start, offset, start_index, end_index)
      start += offset
      self.start_time = start + (start_index * 30).minutes
      self.end_time = start + (end_index * 30).minutes
    end

    def refresh_shift_subject
      self.subject = assigned_to.name + start_time.in_time_zone.strftime(' %I:%M:%S %p - ') + end_time.in_time_zone.strftime('%I:%M:%S %p - ') + start_date.to_datetime.in_time_zone.strftime('%a, %b %d')
    end
    
    #this should fix the timing issue with confusing 12.15/12.45am today with 12.15/12.45am tomorrow
    def validate_with_shift_times # see alias_method_chain above
      #s_time = (start_time.hour * 2) + (start_time.min/30)
      #e_time = (params[:issue][:end_time].hour * 2) + (params[:issue][:end_time].min/30)

      #if (e_time<=s_time) && (e_time == 0 || e_time == 1)
      #  #errors.add :due_date, :greater_than_start_date
      #  end_time = Issue.time_list[e_time+48]  #assuming user knows what he's doing, automatically adjusts the time to next day
      #end

      if self.end_time and self.start_time and self.end_time <= self.start_time
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

    def times_changed?
      if self.start_time_changed? || self.end_time_changed?
        return true
      else
        return false
      end
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
    
    def recreate_timeslots # for now, just orphans all bookings and runs create again.
      self.bookings.uniq.each do |booking|
        booking.orphan
      end
      self.timeslots.clear
      self.create_timeslots
    end
    
    #cancels all bookings associated when issue is deleted
    def cancel_bookings
      self.bookings.each do |booking|
        booking.cancel
      end
    end    
  end
end


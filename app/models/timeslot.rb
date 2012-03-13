class Timeslot < ActiveRecord::Base #timeslots are 30 minute periods during which a lab coach is available
  belongs_to :issue #timeslots belong to shifts, which we are using redmine "issues" for
  has_one :booking, :dependent => :nullify #a timeslot can have one booking, if the timeslot is destroyed the booking's timeslot_id is set to nil
  
  def self.booked
    all.select{|s| s.booking.present? }
  end
  
  def self.open
    all.select{|s| s.booking.nil? }
  end
  
  def start_time #timeslots only have an integer, slot_time, to express their lenth in 30 minute increments from the start of the shift (issue)
    self.issue.start_time + (slot_time * 30).minutes #so, the start time is the start of the shift advanced by slot_time. minutes is a native ruby method for datetime
  end
  
  def end_time
    self.issue.start_time + ((slot_time * 30) + 30).minutes #the end of the slot is 30 minutes after start_time
  end
  
  def slot_date #takes the start date from the date of the shift
    self.issue.start_date
  end
  
  def coach #the lab coach hosting the timeslot
    self.issue.assigned_to
  end
  
  def open? #boolean check: is the timeslot open?
    if self.booking.present? #&& ( self.start_time < DateTime.now )
      return false
    else
      return true
    end
  end
  def booked? #is the timeslot booked? I guess I was just too lazy to use open?
    if self.booking.present? #&& ( self.start_time < DateTime.now )
      return true
    else
      return false
    end
  end
end

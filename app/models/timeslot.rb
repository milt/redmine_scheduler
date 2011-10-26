class Timeslot < ActiveRecord::Base
  belongs_to :issue
  has_one :booking, :dependent => :nullify
  
  def start_time
    self.issue.start_time + (slot_time * 30).minutes
  end
  
  def end_time
    self.issue.start_time + ((slot_time * 30) + 30).minutes
  end
  
  def slot_date
    self.issue.start_date
  end
  
  def coach
    self.issue.assigned_to
  end
  
  def open?
    if self.booking.present? && ( self.start_time < DateTime.now )
      return false
    else
      return true
    end
  end
  def booked?
    if self.booking.present? && ( self.start_time < DateTime.now )
      return true
    else
      return false
    end
  end
end

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
  
end

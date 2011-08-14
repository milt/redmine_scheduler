class Timeslot < ActiveRecord::Base
  belongs_to :issue
  has_one :booking, :dependent => :nullify
  
  def start_time
    self.issue.start_time.strftime("%I:%M %P")
  end
  
end

class Timeslot < ActiveRecord::Base #timeslots are 30 minute periods during which a lab coach is available
  belongs_to :issue #timeslots belong to shifts, which we are using redmine "issues" for
  belongs_to :booking

  scope :booked, lambda { { :conditions => "booking_id IS NOT NULL" } }
  scope :open, lambda { { :conditions => "booking_id IS NULL" } }

  def self.limit_to_skills(*skills)
    joins(issue: {user: :skills}).where("skills.id IN (?)", skills.map(&:id))
  end

  def self.limit_to_coaches(*coaches)
    joins(:issue).where("assigned_to_id IN (?)", coaches.map(&:id))
  end

  def self.from_date_time(date_time)
    joins(:issue).where("start_time >= ?", date_time)
  end

  def self.until_date_time(date_time)
    joins(:issue).where("end_time <= ?", date_time)
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

  def self.from_time(date)
    slots = []
    Issue.lcshift.from_date(date).map {|i| slots += i.timeslots}
    return slots
  end

  def self.after_now
    from_time(Date.today).select {|slot| slot.start_time >= DateTime.now }
  end

  def coach #the lab coach hosting the timeslot
    self.issue.assigned_to
  end

  def skills
    self.issue.assigned_to.skills
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

  #tried using this with search form partial, doesn't work
  def get_skill_names(skill)
    skill_names = []
    skills.each do |skill|
      skill_names << skill.name
    end
    return skill_names
  end

end

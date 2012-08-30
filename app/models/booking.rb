class Booking < ActiveRecord::Base
  has_many :timeslots, :dependent => :nullify
  has_many :issues, :through => :timeslots
  attr_accessible :name, :phone, :email, :project_desc
  validates_presence_of :name, :phone, :email, :project_desc #all form fields must exist be non-nil 
  validates_length_of :name, :email, :maximum => 127 #name can't be over 127 chars
  validates_length_of :phone, :maximum => 16 # phone max length of 16 chars
  validates_length_of :project_desc, :maximum => 1024 #limit the description field
  default_scope :order => 'apt_time ASC' #default sort order of Bookings
  named_scope :future, lambda { { :conditions => ["apt_time >= ?", Date.today] } }
  #named_scope :booked, lambda { { :conditions => "timeslot_id IS NOT NULL" } }
  named_scope :cancelled, lambda { { :conditions => { :cancelled => true } } }
  named_scope :orphaned, lambda { { :conditions => { :cancelled => false } } }
  validate :cannot_create_across_issues, :cannot_create_without_timeslots
  after_validation_on_create :set_apt_time

  def cannot_create_across_issues
    errors.add_to_base("Bookings cannot span multiple shifts.") if
          lambda { self.issues.uniq.count > 1 }
  end

  def cannot_create_without_timeslots
    errors.add_to_base("Bookings must have timeslots.") if
          lambda { self.issues.uniq.count < 1 }
  end

  def set_apt_time
    self.apt_time = self.timeslots.sort_by(&:slot_time).first.start_time
  end

  def cancel
    self.timeslots.clear
    self.cancelled = true
    self.save
  end

  def orphan
    self.timeslots.clear
    self.cancelled = false
    self.save
  end

  def coach
    self.timeslots.first.coach
  end

end

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
  named_scope :orphaned, lambda { { :conditions => { :cancelled => nil, :timeslot_id => nil } } }


  def coach
    self.issue.first.assigned_to
  end

end

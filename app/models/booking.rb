class Booking < ActiveRecord::Base
  belongs_to :coach, :class_name => "User"
  belongs_to :author, :class_name => "User"
  has_many :timeslots, :dependent => :nullify
  has_many :issues, :through => :timeslots
  attr_accessible :name, :phone, :email, :project_desc
  validates :name, :phone, :email, :project_desc, presence: true #all form fields must exist be non-nil 
  validates :name, :email, length: {maximum: 127} #name can't be over 127 chars
  validates :phone, length: {maximum: 16} # phone max length of 16 chars
  validates :project_desc, length: {maximum: 4096}
  default_scope :order => 'apt_time ASC' #default sort order of Bookings
  scope :future, lambda { { :conditions => ["apt_time >= ?", Date.today] } }
  scope :cancelled, lambda {{:conditions => {:cancelled => true }}}
  scope :orphaned, lambda {{:conditions => {:cancelled => false }}}
  scope :from_date, lambda {|d| {:conditions => ["apt_time >= ?", d]}}    #similar to from/until date in issue_patch.rb
  scope :until_date, lambda {|d| {:conditions => ["apt_time <= ?", d+1]}}  #weird occurrance when using d, misses bookings on the until date
  validate :cannot_create_across_issues, :cannot_create_without_timeslots, on: :create
  validate :cannot_update_active_without_timeslots, on: :update
  after_validation :set_apt_time, :set_coach, :set_author, on: :create

  def cannot_create_across_issues
    errors.add_to_base("Bookings cannot span multiple shifts.") if
          self.timeslots.map(&:issue_id).uniq.count > 1
  end

  def cannot_create_without_timeslots
    errors.add_to_base("Bookings must have timeslots.") if
          self.timeslots.empty?
  end

  def cannot_update_active_without_timeslots
    errors.add_to_base("Bookings must have at least one timeslot") if
          self.timeslots.empty? && self.cancelled.nil?
  end

  def set_apt_time
    self.apt_time = self.timeslots.sort_by(&:slot_time).first.start_time
  end

  def set_coach
    self.coach = self.timeslots.sort_by(&:slot_time).first.coach
  end

  def set_author
    self.author = User.current
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

end

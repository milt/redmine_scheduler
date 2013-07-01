class Timesheet < ActiveRecord::Base
  unloadable
  has_many :time_entries, :dependent => :nullify
  belongs_to :user       # possible to divide user between employee and staff/boss?
  has_one :wage, :through => :user
  attr_accessible :submitted, :approved, :user_id, :weekof, :notes    #not sure if necessary

  #validates :user_id, uniqueness: {scope: :weekof, message: "User can only have one timesheet per pay period"}
  #validates_presence_of :user_id, :pay_period #, :print_date
  validates :user_id, :weekof, presence: true
  # validates_presence_of :print_date,
  #   :on => :update,
  #   :if => "submitted.present?",
  #   :message => "Cannot submit before print."

  validates :submitted, presence: true, :on => :update, if: "approved.present?"

  before_create :submit_now

  default_scope :order => 'weekof ASC'
  scope :for_user, lambda {|u| { :conditions => { :user_id => u.id } } }
  #named scopes for submitted
  scope :is_submitted, lambda { { :conditions => "submitted IS NOT NULL" } }
  scope :is_not_submitted, lambda { { :conditions => "submitted IS NULL" } }
  scope :submitted_from, lambda {|d| { :conditions => ["submitted >= ?", d] } }
  scope :submitted_to, lambda {|d| { :conditions => ["submitted <= ?", d] } }
  scope :submitted_on, lambda {|d| { :conditions => ["submitted = ?", d] } }
  #named scopes for printed
  scope :is_printed, lambda { { :conditions => "print_date IS NOT NULL" } }
  scope :is_not_printed, lambda { { :conditions => "print_date IS NULL" } }
  scope :printed_from, lambda {|d| { :conditions => ["print_date >= ?", d] } }
  scope :printed_to, lambda {|d| { :conditions => ["print_date <= ?", d] } }
  scope :printed_on, lambda {|d| { :conditions => ["print_date = ?", d] } }
  #named scopes for approved
  scope :is_approved, lambda { { :conditions => "approved IS NOT NULL" } }
  scope :is_not_approved, lambda { { :conditions => "approved IS NULL" } }
  scope :approved_from, lambda {|d| { :conditions => ["approved >= ?", d] } }
  scope :approved_to, lambda {|d| { :conditions => ["approved <= ?", d] } }
  scope :approved_on, lambda {|d| { :conditions => ["approved = ?", d] } }
  #named scopes for weekof
  scope :weekof_from, lambda {|d| {:conditions => ["weekof >= ?", d] } }
  scope :weekof_to, lambda {|d| { :conditions => ["weekof <= ?", d] } }
  scope :weekof_on, lambda {|d| { :conditions => ["weekof = ?", d] } }

  def self.rejected
    where(submitted: nil, approved: nil)
  end

  @@state_actions = {
    :draft      => {
      :admin => [['Edit', :edit], ['Delete', :delete], ['Submit', :submit]],
      :staff => [['Edit', :edit], ['Delete', :delete], ['Submit', :submit]]
    },
    :submitted  => {
      :admin => [['Print', :print], ['Show', :show], ['Approve', :approve], ['Delete', :delete], ['Reject', :reject]],
      :staff => [['Print', :print], ['Show', :show]]
    },
    :approved       => {
      :admin => [['Print', :print], ['Show', :show]],
      :staff => [['Print', :print], ['Show', :show]]
    }
  }

  #status bools
  def printed?
    self.print_date.present?
  end

  def submitted?
    self.submitted.present?
  end

  def approved?
    self.approved.present?
  end

  #status checker
  def status
    if !self.submitted? && !self.approved?
      return :draft
    elsif self.submitted? && !self.approved?
      return :submitted
    elsif self.submitted? && self.approved?
      return :approved
    else
      return nil
    end
  end
  
  def actions
    @@state_actions[self.status]
  end

  #methods used before time entries are attached.
  #retrieves all time entries for the week in question
  def entries_for_week
    d = self.weekof.to_date
    TimeEntry.foruser(self.user).from_date(d).until_date(d + 7.days)
  end


  #returns the total hours spent on the week
  def find_total_hours
    entries_for_week.inject(0) {|sum, x| sum + x.hours}
  end
  
  #what days are covered by this timesheet? Return an array of dates, why don't you.
  def dates
    dates = []
    for d in 0..6
      dates << self.weekof.to_date + d.days
    end
    return dates
  end

  # THESE NEED TO GO AWAY----------------------------------------------
  #can be used to find entries for a given day before commit.
  def entries_for_day(day)
    day = day.downcase.to_sym if day.class != Symbol
    case day
    when :monday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date}
    when :tuesday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 1.days}
    when :wednesday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 2.days}
    when :thursday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 3.days}
    when :friday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 4.days}
    when :saturday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 5.days}
    when :sunday
      return self.entries_for_week.select {|e| e.spent_on == self.weekof.to_date + 6.days}
    else
      return nil
    end
  end

  def find_hours_for_day(day)
    self.entries_for_day(day).inject(0) {|sum, x| sum + x.hours}
  end
  #--------------------------------------------------------------------------
  

  def status_string
    if self.approved?
      return "approved"
    elsif !self.approved? && self.submitted?
      return "Submitted, but not approved"
    else
      return "Not submitted and not approved"
    end
  end

  #commit time entries to timesheet:
  def commit_time_entries
    self.time_entries = user.time_entries.not_on_timesheet.on_week(weekof)
  end
  
  #release entries from the sheet.
  def release
    if !self.time_entries.empty?
      self.time_entries.clear
      return true
    else
      return false
    end
  end

  #returns the total hours spent on the week after commit
  def total_hours
    self.time_entries.inject(0) {|sum, x| sum + x.hours}
  end

  #can be used to find entries for a given day before commit.
  def time_entries_for_day(day)
    day = day.downcase.to_sym if day.class != Symbol
    case day
    when :monday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date}
    when :tuesday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 1.days}
    when :wednesday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 2.days}
    when :thursday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 3.days}
    when :friday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 4.days}
    when :saturday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 5.days}
    when :sunday
      return self.time_entries.select {|e| e.spent_on == self.weekof.to_date + 6.days}
    else
      return nil
    end
  end

  def hours_for_day(day)
    self.time_entries_for_day(day).inject(0) {|sum, x| sum + x.hours}
  end


  def print_now
    self.print_date = DateTime.now
  end

  # def submit_now
  #   if self.commit
  #     self.submitted = DateTime.now
  #     return true
  #   else
  #    return false
  #   end
  # end

  def submit_now
    self.submitted = DateTime.now
  end

  def reject_now
    self.time_entries.clear
    self.submitted = self.approved = nil
    self.save
  end
  # def reject_now
  #   if self.release
  #     self.submitted = nil
  #     return true
  #   else
  #     return false
  #   end
  # end

  def approve_now
    self.approved = DateTime.now
    self.approve_time_wage = self.user.wage.amount
  end

  def delete_now
    if self.destroy
      return true
    else
      return false
    end
  end
end

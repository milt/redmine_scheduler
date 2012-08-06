class Timesheet < ActiveRecord::Base
  unloadable
  has_many :time_entries, :dependent => :nullify
  belongs_to :user       # possible to divide user between employee and staff/boss?
  has_one :wage, :through => :user
  attr_accessible :submitted, :approved    #not sure if necessary

  validates_uniqueness_of :user_id, :scope => :weekof,:message => "User can only have one timesheet per pay period"
  #validates_presence_of :user_id, :pay_period #, :print_date
  validates_presence_of :user_id, :weekof
  # validates_presence_of :print_date,
  #   :on => :update,
  #   :if => "submitted.present?",
  #   :message => "Cannot submit before print."

  validates_presence_of :submitted,
    :on => :update,
    :if => "approved.present?",
    :message => "Cannot approve before submission."

  default_scope :order => 'weekof ASC'
  named_scope :for_user, lambda {|u| { :conditions => { :user_id => u.id } } }
  #named scopes for submitted
  named_scope :is_submitted, lambda { { :conditions => "submitted IS NOT NULL" } }
  named_scope :is_not_submitted, lambda { { :conditions => "submitted IS NULL" } }
  named_scope :submitted_from, lambda {|d| { :conditions => ["submitted >= ?", d] } }
  named_scope :submitted_to, lambda {|d| { :conditions => ["submitted <= ?", d] } }
  named_scope :submitted_on, lambda {|d| { :conditions => ["submitted = ?", d] } }
  #named scopes for printed
  named_scope :is_printed, lambda { { :conditions => "print_date IS NOT NULL" } }
  named_scope :is_not_printed, lambda { { :conditions => "print_date IS NULL" } }
  named_scope :printed_from, lambda {|d| { :conditions => ["print_date >= ?", d] } }
  named_scope :printed_to, lambda {|d| { :conditions => ["print_date <= ?", d] } }
  named_scope :printed_on, lambda {|d| { :conditions => ["print_date = ?", d] } }
  #named scopes for approved
  named_scope :is_approved, lambda { { :conditions => "approved IS NOT NULL" } }
  named_scope :is_not_approved, lambda { { :conditions => "approved IS NULL" } }
  named_scope :approved_from, lambda {|d| { :conditions => ["approved >= ?", d] } }
  named_scope :approved_to, lambda {|d| { :conditions => ["approved <= ?", d] } }
  named_scope :approved_on, lambda {|d| { :conditions => ["approved = ?", d] } }
  #named scopes for weekof
  named_scope :weekof_from, lambda {|d| {:conditions => ["weekof >= ?", d] } }
  named_scope :weekof_to, lambda {|d| { :conditions => ["weekof <= ?", d] } }
  named_scope :weekof_on, lambda {|d| { :conditions => ["weekof = ?", d] } }

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
    TimeEntry.foruser(self.user).on_tweek(self.weekof.to_date.cweek)
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
  def commit
    if self.time_entries.empty? && !self.entries_for_week.empty?
      self.time_entries += self.entries_for_week
      return true
    else
      return false
    end
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

  def submit_now
    if self.commit
      self.submitted = DateTime.now
      return true
    else
     return false
    end
  end

  def reject_now
    if self.release
      self.submitted = nil
      return true
    else
      return false
    end
  end

  def approve_now
    self.approved = DateTime.now
  end

  def delete_now
    if self.destroy
      return true
    else
      return false
    end
  end
end

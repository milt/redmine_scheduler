class Timesheet < ActiveRecord::Base
  unloadable
  has_many :time_entries
  belongs_to :user       # possible to divide user between employee and staff/boss?
  has_one :wage, :through => :user
  attr_accessible :submitted, :paid    #not sure if necessary
  #validates_uniqueness_of :user_id, :scope => :pay_period, # only one sheet can be entered for a given time period
  #    :message => "Users can only have one timesheet per pay period."
  validates_uniqueness_of :user_id, :scope => :weekof,:message => "User can only have one timesheet per pay period"
  #validates_presence_of :user_id, :pay_period #, :print_date
  validates_presence_of :user_id, :weekof
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
  #named scopes for paid
  named_scope :is_paid, lambda { { :conditions => "paid IS NOT NULL" } }
  named_scope :is_not_paid, lambda { { :conditions => "paid IS NULL" } }
  named_scope :paid_from, lambda {|d| { :conditions => ["paid >= ?", d] } }
  named_scope :paid_to, lambda {|d| { :conditions => ["paid <= ?", d] } }
  named_scope :paid_on, lambda {|d| { :conditions => ["paid = ?", d] } }
  #named scopes for weekof
  named_scope :weekof_from, lambda {|d| {:conditions => ["weekof >= ?", d] } }
  named_scope :weekof_to, lambda {|d| { :conditions => ["weekof <= ?", d] } }
  named_scope :weekof_on, lambda {|d| { :conditions => ["weekof = ?", d] } }

  @@state_actions = {
    :draft      => [['Print', :print], ['Edit', :edit], ['Show', :show], ['Delete', :delete]],
    :printed    => [['Reprint', :reprint], ['Submit', :submit], ['Show', :show], ['Delete', :delete], ['Reject', :reject]],
    :submitted  => [['Reprint', :reprint], ['Show', :show], ['Pay', :pay], ['Delete', :delete], ['Reject', :reject]],
    :paid       => [['Reprint', :reprint], ['Show', :show]]
  }

  #status bools
  def printed?
    self.print_date.present?
  end

  def submitted?
    self.submitted.present?
  end

  def paid?
    self.paid.present?
  end

  #status checker
  def status
    if !self.printed? && !self.submitted? && !self.paid?
      return :draft
    elsif self.printed? && !self.submitted? && !self.paid?
      return :printed
    elsif self.printed? && self.submitted? && !self.paid?
      return :submitted
    elsif self.printed? && self.submitted? && self.paid?
      return :paid
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
    if self.paid?
      return "Paid"
    elsif !self.paid? && self.submitted?
      return "Submitted, but not paid"
    else
      return "Not submitted and not paid"
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
    if self.commit
      self.print_date = DateTime.now
      return true
    else
     return false
    end
  end

  def reprint
    self.print_date = DateTime.now
  end

  def submit_now
     self.submitted = DateTime.now
  end

  def pay_now
    self.paid = DateTime.now
  end


end

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
  named_scope :weekof_from, lambda {|d| { :conditions => ["weekof >= ?", d] } }
  named_scope :weekof_to, lambda {|d| { :conditions => ["weekof <= ?", d] } }
  named_scope :weekof_on, lambda {|d| { :conditions => ["weekof = ?", d] } }

  def entries
    TimeEntry.foruser(self.user).on_tweek(self.weekof.to_date.cweek)
  end

  #doesn't work
  # def self.search(search)
  #   if search
  #     find(:all, :conditions => [User.firstname == search])   # conditions not condition
  #   else
  #     find(:all)
  #   end
  # end
end

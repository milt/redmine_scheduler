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
  #named_scope :paid

  #doesn't work
  # def self.search(search)
  #   if search
  #     find(:all, :conditions => [User.firstname == search])   # conditions not condition
  #   else
  #     find(:all)
  #   end
  # end
end

class Timesheet < ActiveRecord::Base
  unloadable
  has_many :time_entries
  belongs_to :user
  has_one :wage, :through => :user
  #attr_accessible :pay_period
  validates_uniqueness_of :user_id, :scope => :pay_period, # only one sheet can be entered for a given time period
      :message => "Users can only have one timesheet per pay period."
  validates_presence_of :user_id, :pay_period #, :print_date
  validates_length_of :name, :maximum => 127
end

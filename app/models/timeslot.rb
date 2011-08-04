class Timeslot < ActiveRecord::Base
  belongs_to :issue
  has_one :booking
end

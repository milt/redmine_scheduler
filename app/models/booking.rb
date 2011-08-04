class Booking < ActiveRecord::Base
  has_many :timeslots
end

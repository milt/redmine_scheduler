class Booking < ActiveRecord::Base
  belongs_to :timeslots
end

class Timeslot < ActiveRecord::Base
  belongs_to :issues
  has_one :booking
end

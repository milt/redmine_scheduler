class Timeslot < ActiveRecord::Base
  belongs_to :issue
  belongs_to :booking
end

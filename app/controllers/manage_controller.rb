class ManageController < ApplicationController
  unloadable


  def index
    @allshifts = Tracker.find_by_name('Lab Coach Shift').issues.all.sort_by {|i| i[:start_time]}
    @alltimeslots = Timeslot.all.sort_by {|t| [t.issue[:start_time], t[:slot_time]]}
    @allbookings = Booking.all
  end

  def schedule
  end
end

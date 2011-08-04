class ManageController < ApplicationController
  unloadable


  def index
    @allshifts = Tracker.find_by_name('Lab Coach Shift').issues.all
    @alltimeslots = Timeslot.all
    @allbookings = Booking.all
  end

  def schedule
  end
end

class ManageController < ApplicationController
  unloadable


  def index
    @allshifts = Tracker.find_by_name('Lab Coach Shift').issues.sort_by(&:start_time).reject {|t| t.start_date < Date.today}
    @alltimeslots = Timeslot.all
    @allbookings = Booking.all
    @selected = []
  end

  def today
    @todayshifts = Issue.all.select {|i| (i.assigned_to == User.current) && (i.start_date == Date.today) }
  end

  def schedule
  end
end

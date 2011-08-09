class BookingController < ApplicationController
  unloadable


  def index
    @timeslots = Timeslot.all
    @unbooked = @timeslots.select {|timeslot| timeslot.booking.nil?}
    
  end

  def book
  end
end

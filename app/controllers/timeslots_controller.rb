class TimeslotsController < ApplicationController
  unloadable

  def index
  	@timeslots = Timeslot.after_now
  end

  def book
  end
end

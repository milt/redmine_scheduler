class ManageController < ApplicationController
  unloadable

  def index
    #@allshifts = Tracker.find_by_name('Lab Coach Shift').issues.sort_by(&:start_time).reject {|t| t.start_date < Date.today}
    #@bookedtimeslots = Timeslot.all.select {|t| t.booked? }
    #@allbookings = Booking.all
    @booked = Booking.all.select {|b| b.timeslot_id.present? && (b.apt_time > DateTime.now)}
    if params[:sort_col].present?
      case params[:sort_col].to_i
      when 0
        @booked = @booked.sort_by {|b| b.apt_time}
      when 1
        @booked = @booked.sort {|a, b| a.timeslot.coach.firstname.downcase <=> b.timeslot.coach.firstname.downcase}
      when 2
        @booked = @booked.sort_by {|b| b.name.downcase}
      when 3
        @booked = @booked.sort {|a, b| a.timeslot.issue_id <=> b.timeslot.issue_id}
      else
        @booked = @booked.sort_by {|b| b.apt_time}
      end
    end
    @cancelled = Booking.all.select {|b| b.timeslot_id.nil? }
  end

  def today
    @allshiftstoday = Issue.all.select {|i| i.start_date == Date.today }
    @todayshifts = Issue.all.select {|i| (i.assigned_to == User.current) && (i.start_date == Date.today) }
  end
  
  def show
    @booking = Booking.find(params[:booking_id])
  end

  def cancel
    @booking = Booking.find(params[:booking_id])
    @booking.timeslot_id = nil
    @booking.cancelled = true
    
     respond_to do |format|
       if @booking.save
         flash[:notice] = 'Booking cancelled. Timeslot should be available.'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking, :status => :cancelled,
                     :location => @booking }
       else                                               
         flash[:warning] = 'I canny cancel. Something is not right'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking.errors,
                     :status => :unprocessable_entity }
       end
    end
  end

  def schedule
  end
end

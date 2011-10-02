class ManageController < ApplicationController
  unloadable

  def index
    allbookings = Booking.all.select {|b| b.apt_time > DateTime.now}
    @booked = allbookings.select {|b| b.timeslot_id.present?}
    nullified = allbookings.select {|b| b.timeslot_id.nil?}
    @orphaned = nullified.select {|b| b.cancelled.nil?}
    if @orphaned.present?
      flash[:warning] = 'There are ' + @orphaned.count.to_s + ' bookings to be rescheduled! Please address these to make this message go away!'
    end
    @cancelled = nullified.select {|b| b.cancelled == true}
    
    #bodgy sort handlin! sort_col is for active bookings, sort_o_col is for orphaned bookings, sort_c_col is for cancelled bookings.
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

    if params[:sort_o_col].present?
      case params[:sort_o_col].to_i
      when 0
        @orphaned = @orphaned.sort_by {|b| b.apt_time}
      when 2
        @orphaned = @orphaned.sort_by {|b| b.name.downcase}
      else
        @orphaned = @orphaned.sort_by {|b| b.apt_time}
      end
    end
    
    if params[:sort_c_col].present?
      case params[:sort_c_col].to_i
      when 0
        @cancelled = @cancelled.sort_by {|b| b.apt_time}
      when 2
        @cancelled = @cancelled.sort_by {|b| b.name.downcase}
      else
        @cancelled = @cancelled.sort_by {|b| b.apt_time}
      end
    end
  end

  def today
    @allshiftstoday = Issue.all.select {|i| (i.start_date == Date.today) && i.is_frontdesk_shift? }
    @todayshifts = @allshiftstoday.select {|i| i.assigned_to == User.current}
    @alllcshiftstoday = Issue.all.select {|i| (i.start_date == Date.today) && i.is_labcoach_shift? }
    @todaylcshifts = @allshiftstoday.select {|i| i.assigned_to == User.current}
  end
  
  def show
    @booking = Booking.find(params[:booking_id])
  end

  def cancel
    @booking = Booking.find(params[:booking_id])
    unless @booking.timeslot_id.nil?
      @booking.project_desc = "[Original Staff Member: " + @booking.timeslot.coach.firstname + "] " + @booking.project_desc
    end
    @booking.timeslot_id = nil
    @booking.cancelled = true
    
     respond_to do |format|
       if @booking.save
         flash[:notice] = 'Booking cancelled. Timeslot should be available if one existed.'
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

class BookingController < ApplicationController
  unloadable

  before_filter :find_open_slot, :only => [:new, :book, :rebook] #makes sure the timeslot is valid on new booking

  #index page. users select skills they want help with, see available shifts
  def index
    #check for incoming search parameters, and instantiate an empty array if there are none.
    #'filter' has nothing to do with before_filter, is the array of skills selected from the _checkform partial
    if params[:skill_ids].nil?
      #make a blank array to be filled, or there will be a crash
      @filter = []
    else
      @filter = params[:skill_ids]
    end
    
    #todo: clean up variables that don't need to be @ in this section
    @skills = Skill.all #all selectable skills
    @skillcats = Skillcat.all #skill categories for pulldown
    @selskills = @skills.select {|s| @filter.include?(s.id.to_s)} #selected skills are selected based on the query array
    #selected shifts, users and dates are found on a query. If there is no query, instantiate an empty one
    @selshifts = []
    @selusers = []
    @seldates = []
    #the cutoff date determines how far the system should show open shifts
    #todo: make this user-configurable
    cutoff = Date.today + 365
    
    #for each selected skill, find shifts with open slots. For table formatting, pull all selected users and dates
    @selskills.each do |skill|
      skill.shifts(cutoff).each do |shift|
        if shift.open_slots?
          unless @selshifts.include?(shift)
            @selshifts << shift
            @selusers << shift.assigned_to unless @selusers.include?(shift.assigned_to)
            @seldates << shift.start_date unless @seldates.include?(shift.start_date)
          end
        end
      end
    end
    @seldates = @seldates.sort
    @selusers = @selusers.sort_by(&:firstname)
  end
  
  def new
    #temporary, for "re-attaching" Bookings to a new shift while this is being used lab-only.
    @orphaned = Booking.all.select {|b| (b.timeslot_id.nil? && b.cancelled.nil?) && (b.apt_time > DateTime.now)}
  end
  
  def book #make a booking with a lab coach
    
    @booking = @timeslot.build_booking(params[:booking])
    @booking.apt_time = @timeslot.start_time

    respond_to do |format| #triggers on the submission of the form. look for the format function in the view
      if @booking.save #if model validations and other stuff happens OK, respond to the user and redirect, we don't really use the XML ones
         flash[:notice] = 'Booking was successfully created.'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking, :status => :created,
                     :location => @booking }
      else #kick the user back to the form.
         flash[:warning] = 'Invalid Options... Try again!'
         format.html { redirect_to :action => "new", :timeslot_id => params[:timeslot_id]}
         format.xml  { render :xml => @booking.errors,
                     :status => :unprocessable_entity }
      end
    end
  end
  
  def rebook #jury-rigged action to reschedule bookings to available timeslots. needs to be redone
    @booking = Booking.find(params[:booking_id])
    @timeslot.booking = @booking
    @booking.apt_time = @timeslot.start_time
    
    respond_to do |format|
      if @booking.save
         flash[:notice] = 'Booking was successfully rescheduled.'
         format.html { redirect_to :action => "index" }
         format.xml  { render :xml => @booking, :status => :created,
                     :location => @booking }
      else                                               
         flash[:warning] = 'Invalid Options... Try again!'
         format.html { redirect_to :action => "new", :timeslot_id => params[:timeslot_id]}
         format.xml  { render :xml => @booking.errors,
                     :status => :unprocessable_entity }
      end
    end
  end
  
  private #private class methods, used here for the before_filter
  
  def find_open_slot
    begin
      @timeslot = Timeslot.find(params[:timeslot_id])
      unless @timeslot.open?
        if @timeslot.booking.present?
          flash[:warning] = 'This shift has already been booked. Please select another.'
          redirect_to :action => "index"
        else
          flash[:warning] = 'It is too late to book this shift. Please select another.'
          redirect_to :action => "index"
        end
      end
    rescue
      flash[:warning] = 'Could not find timeslot.'
      redirect_to :action => "index"
    end
  end
  
end

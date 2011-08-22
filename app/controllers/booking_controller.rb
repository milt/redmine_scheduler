class BookingController < ApplicationController
  unloadable

  before_filter :find_open_slot, :only => [:new, :book]

  def index
    #check for incoming search parameters, and instantiate an empty array if there are none.
    if params[:skill_ids].nil?
      @filter = []
    else
      @filter = params[:skill_ids]
    end
    
    #@timeslots = Timeslot.all
    @skills = Skill.all
    @skillcats = Skillcat.all
    @selskills = @skills.select {|s| @filter.include?(s.id.to_s)}
    #@allshifts = Issue.all.select {|i| i.is_labcoach_shift? && (i.start_date <= (Date.today + 14))}
    @selshifts = []
    @selusers = []
    @seldates = []
    cutoff = Date.today + 14
    
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
    
  end
  
  
  def book
    
    @booking = @timeslot.build_booking(params[:booking])
    
    respond_to do |format|
      if @booking.save
         flash[:notice] = 'Booking was successfully created.'
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
  
  private
  
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

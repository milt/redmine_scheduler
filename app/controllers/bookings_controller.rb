class BookingsController < ApplicationController
  unloadable
  before_filter :find_timeslots, :only => [:new, :create]
  before_filter :find_booking, :only => [:show, :edit]

  def index
    find_params

    if @date.nil?
      @date = Date.today  #default selected date
    end 

    @bookings = Booking.from_date(@from).until_date(@to)

    if params[:sort_by] == 'name'
        @bookings = @bookings.sort_by(&:name)
    end    
    
    if params[:sort_by] == 'coach'
        @bookings = @bookings.sort_by(&:coach)
    end    
    
    if params[:sort_by] == 'start_time'
        @bookings = @bookings.sort_by(&:apt_time)
    end    
    
    filter_active(@bookings)
    filter_orphaned(@bookings)
    filter_cancelled(@bookings)
  end

  def new
    @booking = Booking.new(params[:booking])
  end

  def create
    @booking = Booking.new(params[:booking])
    @booking.timeslots << @timeslots

    respond_to do |format|
      if @booking.save
        flash[:notice] = 'Booking was successfully created.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @booking, :status => :created,
                    :location => @booking }
      else                                               
        flash[:warning] = 'Invalid options'
        format.html { render :action => "new", :booking => params[:booking], :slot_ids => params[:slot_ids] }
        format.xml  { render :xml => @booking.errors,
                    :status => :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  private

  def find_params
    if params[:from].present?
      @from = Date.new(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
    else
      @from = Date.today
    end

    if params[:to].present?
      @to = Date.new(params[:to][:year].to_i, params[:to][:month].to_i, params[:to][:day].to_i)
    else
      @to = Date.today + 2.weeks
    end
  end

  def filter_date(bookings, date)
    @bookings = bookings.select {|b| b.apt_time.to_date >= date}
  end

  def filter_orphaned(bookings)
    @orph_bookings = bookings.select {|b| b.cancelled == false}.paginate(:page => params[:page], :per_page => 4)
  end

  def filter_cancelled(bookings)
    @canc_bookings = bookings.select {|b| b.cancelled == true}.paginate(:page => params[:page], :per_page => 4)
  end

  def filter_active(bookings)
    @act_bookings = bookings.select {|b| b.cancelled == nil}.paginate(:page => params[:page], :per_page => 4)
  end

  def find_timeslots
    if params[:slot_ids].present?
      @timeslots = params[:slot_ids].map {|id| Timeslot.find(id)}
    else
      flash[:warning] = 'Cannot make a new Booking without some timeslots. Pick some here and click "Book..."'
      redirect_to :controller => 'timeslots', :action => 'find'
    end

    if @timeslots.detect {|slot| slot.booked?}
      flash[:warning] = 'One or more timeslots is already booked. Please select available slots here and click "Book..."'
      redirect_to :controller => 'timeslots', :action => 'find'
    end

    # send user back if the timeslots cover more than one shift. Suspenders and a belt.
    if @timeslots.map(&:issue_id).uniq.count > 1
      flash[:warning] = 'You can not make a booking that covers more than one shift. Please try again.'
      redirect_to :controller => 'timeslots', :action => 'find'
    end
  end

  def find_booking
    if params[:id].present?
      @booking = Booking.find(params[:id])
    else
      flash[:warning] = 'No ID specified.'
      redirect_to :action => 'index'
    end
  end
end

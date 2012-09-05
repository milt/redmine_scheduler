class BookingsController < ApplicationController
  unloadable
  before_filter :find_timeslots, :only => [:new, :create]
  before_filter :find_booking, :only => [:show, :edit]

  def index
    flash[:warning] = "the selected date is #{params[:sel_date]}"
    if params[:sel_date].present?
      @date = Date.new(params[:sel_date][:year].to_i, params[:sel_date][:month].to_i, params[:sel_date][:day].to_i)
      flash[:notice] = "the date selected is #{@date}"
    end

    if params[:pag_date].present?
      @date = params[:pag_date]
    end

    if @date.nil?
      @date = Date.new(Time.now.year, Time.now.month, Time.now.day)  #default selected date
    end 

    @bookings = Booking.all
    @act_bookings = Booking.all

    filter_date(@bookings, @date) unless @date.nil?
    filter_active(@bookings)
    #flash[:warning] = "the current date selected is #{@bookings}"
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

  def filter_date(bookings, date)
    @bookings = bookings.select {|b| b.apt_time.to_date >= date}
  end

  def filter_orphaned(bookings)
    @orph_bookings = bookings.select {|b| b.cancelled == false}.paginate(:page => params[:orph_bookings], :per_page => 1)
  end

  def filter_cancelled(bookings)
    @canc_bookings = bookings.select {|b| b.cancelled == true}.paginate(:page => params[:canc_bookings], :per_page => 1)
  end

  #ordering not working
  def filter_active(bookings)
    if params[:sort] == 'act_by_name'
      @act_bookings = params[:bookings].select {|b| b.cancelled == nil}.paginate(:page => params[:act_bookings], :per_page => 4).order("name")
    else
      @act_bookings = @bookings.select {|b| b.cancelled == nil}.paginate(:page => params[:act_bookings], :per_page => 4)
    end
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

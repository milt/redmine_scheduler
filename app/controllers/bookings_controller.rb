class BookingsController < ApplicationController
  unloadable
  before_filter :find_timeslots, :only => :create
  before_filter :find_booking, :only => [:show, :edit, :update, :cancel]
  authorize_resource

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
    
    if params[:sort_by] == 'apt_time'
        @bookings = @bookings.sort_by(&:apt_time)
    end    
    
    filter_active(@bookings)
    filter_orphaned(@bookings)
    filter_cancelled(@bookings)
  end

  def new
    @booking = Booking.new(params[:booking])
    @timeslot = Timeslot.new

    timeslot_search_params


    @timeslots = Timeslot.open.from_date_time(@from).until_date_time(@until).limit_to_coaches(*@coaches).page(params[:page]).per(10)

    respond_to do |format|
      format.html # new.html.erb
      #format.json { render json: @timeslots }
      format.js
    end
  end

  def create
    @booking = Booking.new(params[:booking])

    if params[:me].present?
      @booking.name = User.current.name
    end

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

  def update

    @old_slots = @booking.timeslots
    
    if params[:slot_ids].present?
      @timeslots = params[:slot_ids].map {|id| Timeslot.find(id)}
    end

    #TODO.. process the changes in timeslot
    @booking.attributes = params[:booking]

    if params[:me].present?
      @booking.name = User.current.name
    end
    
    @booking.timeslots = @timeslots
    respond_to do |format|
      if @booking.save
        flash[:notice] = 'Booking was successfully updated.'
        format.html { redirect_to :action => "show", :id => @booking }
        format.xml  { render :xml => @booking, :status => :updated,
                    :location => @booking }
      else
        @booking.timeslots = @old_slots #go back to orig slots
        flash[:warning] = 'Invalid options'
        format.html { render :action => "edit", :booking => @booking, :slot_ids => params[:slot_ids] }
        format.xml  { render :xml => @booking.errors,
                    :status => :unprocessable_entity }
      end
    end
  end

  def cancel
    respond_to do |format|
      if @booking.cancel
        flash[:notice] = 'Booking was successfully cancelled.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @booking, :status => :updated,
                    :location => @booking }
      else                                               
        flash[:warning] = "Couldn't cancel."
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @booking.errors,
                    :status => :unprocessable_entity }
      end
    end
  end

  private

  def timeslot_search_params
    if params[:from]
      @from = DateTime.new(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i, params[:from][:hour].to_i, params[:from][:minute].to_i, 0, DateTime.now.zone)
      @from = DateTime.now if @from < DateTime.now
    else
      @from = DateTime.now + 30.minutes
    end

    if params[:until]
      @until = DateTime.new(params[:until][:year].to_i, params[:until][:month].to_i, params[:until][:day].to_i, params[:until][:hour].to_i, params[:until][:minute].to_i, 0, DateTime.now.zone)
    else
      @until = DateTime.now + 2.days
    end

    if @from > @until
      @until = @from
    end

    @all_coaches = Group.stustaff.first.users
    @all_skills = Skill.all

    if params[:skill_ids]
      @skills = Skill.find(params[:skill_ids])
    else
      @skills = @all_skills
    end

    if params[:coach_ids]
      @coaches = User.with_skills(*@skills).find(params[:coach_ids])
    else
      @coaches = User.with_skills(*@skills)
    end

  end

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
    @orph_bookings = bookings.orphaned.page(params[:page]).per(4)
  end

  def filter_cancelled(bookings)
    @canc_bookings = bookings.cancelled.page(params[:page]).per(4)
  end

  def filter_active(bookings)
    @act_bookings = bookings.active.page(params[:page]).per(4)
  end

  def find_timeslots
    if params[:slot_ids].present?
      @timeslots = params[:slot_ids].map {|id| Timeslot.find(id)}
      if @timeslots.detect {|slot| slot.booked?}
        flash[:warning] = 'One or more timeslots is already booked. Please select available slots here and click "Book..."'
        redirect_to :controller => 'timeslots', :action => 'find'
      end
      # send user back if the timeslots cover more than one shift. Suspenders and a belt.
      if @timeslots.map(&:issue_id).uniq.count > 1
        flash[:warning] = 'You can not make a booking that covers more than one shift. Please try again.'
        redirect_to :controller => 'timeslots', :action => 'find'
      end
    else
      @timeslots = []
      # flash[:warning] = 'Cannot make a new Booking without some timeslots. Pick some here and click "Book..."'
      # redirect_to :controller => 'timeslots', :action => 'find'
    end
  end

  def find_booking
    if params[:id].present?
      @booking = Booking.find(params[:id])
      @timeslots = @booking.timeslots
      if @timeslots.present?
        @shift = @timeslots.first.issue
      end
    else
      flash[:warning] = 'No ID specified.'
      redirect_to :action => 'index'
    end
  end
end

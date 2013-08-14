class BookingsController < ApplicationController
  unloadable
  before_filter :find_timeslots, :only => :create
  before_filter :find_booking, :only => [:show, :edit, :update, :cancel]
  authorize_resource

  def index
    find_index_params

    @bookings = Booking.between(@from,@until).with_coaches(*@coaches).search(params[:search])
    @booking = Booking.new

    @active = @bookings.active.page(params[:active_page]).per(10)
    @cancelled = @bookings.cancelled.page(params[:cancelled_page]).per(10)
    @orphaned = @bookings.orphaned.page(params[:orphaned_page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @booking = Booking.new(params[:booking])
    @timeslot = Timeslot.new

    timeslot_search_params

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @times }
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
    timeslot_search_params

    respond_to do |format|
      format.html
      format.js
    end
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
      if @booking.new_record? #handle use on edit
        @from = DateTime.now + 30.minutes
      else
        @from = @booking.timeslots.order(:slot_time).first.start_time - 1.hour
      end
    end

    if params[:until]
      @until = DateTime.new(params[:until][:year].to_i, params[:until][:month].to_i, params[:until][:day].to_i, params[:until][:hour].to_i, params[:until][:minute].to_i, 0, DateTime.now.zone)
    else
      if @booking.new_record?
        @until = DateTime.now + 2.days
      else
        @until = @booking.timeslots.order(:slot_time).last.end_time + 1.hour
      end
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
      @coaches = User.find(params[:coach_ids])
    else
      @coaches = @all_coaches
    end

    @all_skills_by_skillcat = @all_skills.group_by(&:skillcat)
    @timeslots = Timeslot.from_date_time(@from).until_date_time(@until).limit_to_coaches(*@coaches).limit_to_skills(*@skills) #.order_for_form.uniq

    @timeslots_by_time = @timeslots.group_by(&:start_time)
    @times = Kaminari.paginate_array(@timeslots_by_time.keys).page(params[:page]).per(20)
    @times_by_day = @times.group_by(&:to_date)

  end

  def find_index_params
    if params[:from]
      @from = Date.new(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
    else
      @from = Date.today
    end

    if params[:until]
      @until = Date.new(params[:until][:year].to_i, params[:until][:month].to_i, params[:until][:day].to_i)
    else
      @until = Date.today + 2.weeks
    end

    @all_coaches = Group.stustaff.first.users

    if params[:coach_ids]
      @coaches = User.find(params[:coach_ids])
    else
      @coaches = @all_coaches
    end

  end

  def get_pages
    params[:active_page] ? @active_page = params[:active_page].to_i : @active_page = 1
    params[:cancelled_page] ? @cancelled_page = params[:cancelled_page].to_i : @cancelled_page = 1
    params[:orphaned_page] ? @orphaned_page = params[:orphaned_page].to_i : @orphaned_page = 1
  end

  def find_timeslots
    if params[:slot_ids].present?
      @timeslots = params[:slot_ids].map {|id| Timeslot.find(id)}
      if @timeslots.detect {|slot| slot.booked?}
        flash[:warning] = 'One or more timeslots is already booked. Please select available slots here and click "Book..."'
        redirect_to :controller => 'bookings', :action => 'new'
      end
      # send user back if the timeslots cover more than one shift. Suspenders and a belt.
      if @timeslots.map(&:issue_id).uniq.count > 1
        flash[:warning] = 'You can not make a booking that covers more than one shift. Please try again.'
        redirect_to :controller => 'bookings', :action => 'new'
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

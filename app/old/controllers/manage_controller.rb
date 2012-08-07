class ManageController < ApplicationController #handles the management/rebooking of lab coach shifts. catch-all for staff functions. needs to be separated from the booking controller when we open up to patrons.
  unloadable
  include ManageHelper
  require 'prawn'
  before_filter :wage_check, :only => [:generate_timesheet, :timesheets]
  before_filter :crying_orphans, :only => [:index, :today]
  
  def index
    @booked = Booking.booked.future #all valid bookings in the future
    #@booked = Booking.booked.paginate(:page => params[:booked_page], :per_page => 10)
    @orphaned = Booking.orphaned.paginate(:page => params[:orphaned_page], :per_page => 2)
    @cancelled = Booking.cancelled.paginate(:page => params[:cancelled_page], :per_page =>4) #hello, its me yes!
    #@cancelled = Booking.cancelled #intentionally cancelled bookings
    
    #@orphaned = Booking.orphaned.order(params[:sort]) #will work with ruby 3.0

    #Nightmare table sort! needs.. fire. sort_col is for active bookings, sort_o_col is for orphaned bookings, sort_c_col is for cancelled bookings.
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
        @cancelled = Booking.cancelled.paginate(:page => params[:cancelled_page], :per_page =>4, :order => 'apt_time')
        #@cancelled = @cancelled.sort_by {|b| b.apt_time}
      when 2
        @cancelled = Booking.cancelled.paginate(:page => params[:cancelled_page], :per_page =>4, :order => 'name')
        #@cancelled = @cancelled.sort_by {|b| b[:name]}
      else
        @cancelled = @cancelled.sort_by {|b| b.apt_time}
      end
    end
  end

  def today #the "My shifts today page"
    @allshiftstoday = Issue.today.open.fdshift
    @todayshifts = Issue.today.open.fdshift.foruser(User.current)
    @alllcshiftstoday = Issue.today.open.lcshift
    @todaylcshifts = Issue.today.open.lcshift.foruser(User.current)
    @mytasks = Issue.open.tasks.foruser(User.current)
    @mygoals = Issue.open.goals.foruser(User.current)

  end
  
  def show #view a single booking
    @booking = Booking.find(params[:booking_id])
  end

  def cancel #cancel a booking (won't reschedule)
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
  
  def generate_timesheet
    @weekof = Date.parse(params[:weekof])   
    name = User.current.firstname + " " + User.current.lastname
    wage = User.current.wage.amount.to_s
    current = Date.today
    beginning = params[:weekof]
    beginning_date = Date.parse(beginning)

    #TODO change the name of the default scopes on TimeEntry for dates, they need to express that the collection includes the dates indicated.
    usrtiments = TimeEntry.foruser(User.current).after(beginning_date).before(beginning_date + 6.days)

    @mon = (usrtiments.select {|t| t.spent_on == @weekof}).inject(0) {|sum, x| sum + x.hours}
    @tue = (usrtiments.select {|t| t.spent_on == (@weekof + 1)}).inject(0) {|sum, x| sum + x.hours}
    @wed = (usrtiments.select {|t| t.spent_on == (@weekof + 2)}).inject(0) {|sum, x| sum + x.hours}
    @thu = (usrtiments.select {|t| t.spent_on == (@weekof + 3)}).inject(0) {|sum, x| sum + x.hours}
    @fri = (usrtiments.select {|t| t.spent_on == (@weekof + 4)}).inject(0) {|sum, x| sum + x.hours}
    @sat = (usrtiments.select {|t| t.spent_on == (@weekof + 5)}).inject(0) {|sum, x| sum + x.hours}
    @sun = (usrtiments.select {|t| t.spent_on == (@weekof + 6)}).inject(0) {|sum, x| sum + x.hours}

    hours = @mon + @tue + @wed + @thu + @fri + @sat + @sun
    if hours == 0
      flash[:warning] = 'You do not have any hours for the specified week!  Add hours to print a timecard.'
      redirect_to :action => 'timesheets'
    else
      send_data (generate_timesheet_pdf(name, wage, current, beginning, @mon, @tue, @wed, @thu, @fri, @sat, @sun),
        :filename => name + "_timecard_from_" + beginning.to_s + "_to_" + (@weekof + 6.days).to_s + ".pdf",
        :type => "application/pdf")
    end
  end
  
  def timesheets
    if params[:date].present? #look for a year and set the current one if not present.
      @year = params[:date][:year]
    else
      @year = Time.current.year.to_s
    end

    yearstart = find_first_monday(Time.current.year + 5.year)
    
    @weeks = []
    c = 0
    52.times do
      @weeks << [(yearstart + c.weeks).strftime("Week of %B %d"), (c + 1)]
      c += 1
    end
    
    if params[:tweek].present?
      @tweek = params[:tweek]
    else
      @tweek = Date.today.cweek
    end

    @work_goals = Issue.goals.open
    @work_shifts = Issue.fdshift + Issue.lcshift
    @work_events = Issue.events
    @weekof = yearstart + (@tweek.to_i - 1).weeks
    usrtiments = TimeEntry.all.select {|t| t.user == User.current }
    @seltiments = usrtiments.select {|t| (t.tyear == @year.to_i) && (t.tweek == @tweek.to_i) }
    @entsbyday = []
    daycount = 0
    7.times do
      day = (@weekof + daycount.days)
      @entsbyday << @seltiments.select {|t| t.spent_on == day}
      daycount += 1
    end

    @totalhours = @seltiments.inject(0) {|sum,x| sum + x.hours}
  end
      
  private
  
  def wage_check
    unless User.current.admin?
      if User.current.wage.nil?
        flash[:warning] = "You don't seem to be assigned a wage. Please speak to your manager."
        redirect_to :action => 'today'
      end
    end
  end
  
  def crying_orphans
    @orphaned = Booking.orphaned #all nullified bookings that weren't cancelled, must be rescheduled
    if @orphaned.present?
      flash[:warning] = 'There are ' + @orphaned.count.to_s + ' bookings to be rescheduled! Please address these to make this message go away!'
    end
  end
  
  def find_first_monday(year)
    days = []
    dcount = 0
    7.times do
      days << (Date.new(year.to_i) + dcount.days)
      dcount += 1
    end
    return days.detect {|day| day.wday == 1 }
  end
end
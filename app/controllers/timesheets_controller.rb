class TimesheetsController < ApplicationController
  unloadable
  #respond_to :json   #what does this mean?

  def index
    @timesheets = Timesheet.all
    #flash[:notice] = 'working'
  end

  def new # the button in Manage>timesheets can point here. The only param needed is the date. Pretty cool...
    @pay_period = Date.parse(params[:pay_period])
    @user = User.current
    @time_entries = @user.time_entries
    @timesheet = Timesheet.new
  end

  def create #make a new timesheet from user input
    @timesheet = Timesheet.new(params[:timesheet])
    @timesheet.paid = false

    respond_to do |format|
      if @timesheet.save
        flash[:notice] = 'Timesheet was successfully created.'
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
      end
    end
  end

  def show
   
  end

  def edit
    #@timesheet = Timesheet.find (params[:id])

    @year = Time.current.year

    yearstart = find_first_monday(@year)
    flash[:notice] = "checking first monday of the year! #{yearstart.inspect}"

    @weeks = []
  
    (0..51).each do |i|
      @weeks << [(yearstart + i.weeks).strftime("Week of %B %d"), (i)]
    end

    @weekof = yearstart + (Date.today.cweek-1).weeks     #.weeks acts like *7
    user_entries = TimeEntry.all.select {|t| t.user == User.current}
    cur_week_entries = user_entries.select {|t| (t.tyear == @year) && (t.tweek == Date.today.cweek)}  #replace with cweek and cwyear
  
    @entries_by_day = []

    (0..6).each do |i| 
      day = (@weekof + i.days)
      @entries_by_day << cur_week_entries.select {|t| t.spent_on == day}
    end
  end

  def update
    @timesheet = Timesheet.find (params[:id])
    @timesheet.update_attributes (params[:timesheet])
    flash[:notice] = "Timesheet has been updated"
    redirect_to @timesheet
  end

  def delete
    @timesheet = Timesheet.find(params[:timesheet])
    flash[:warning] = "what are you doing?"
    @timesheet.destroy
    redirect_to :action => "index"
  end

  def find_first_monday(year)
    # days = []
    # dcount = 0
    # 7.times do
    #   days = (Time.current.year + dcount.days)
    #   if days[dcount].wday == 1{
    #     return days[dcount];
    #   }
    #   dcount += 1
    # end
    # return days.detect {|day| day.wday == 1 }
    
    t = Date.new(year, 1,1).wday     #checks which day (Mon = 1, Sun = 0) is first day of the year 
    if t == 0
      return Date.new(year, 1,2)
    elsif t == 1
      return Date.new (year, 1,1)
    else
      return Date.new (year, 1,(1+8-t))     #cases designed to return the first Monday of the year's date
    end

    #doesn't work
    # for i in 1..8                                       #can also use (1..8).each do |i|
    #   if Date.new(Time.current.year+1, 1, i).cweek == 1
    #     return Date.new(Time.current.year, 1, i)
    #   end
    # end
  end
end
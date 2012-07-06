class TimesheetsController < ApplicationController
  unloadable
  #respond_to :json   #what does this mean?
  include TimesheetHelper
  require "prawn"   #needed for pdf generation

  def index
    @timesheets = Timesheet.all
    #flash[:notice] = 'working'
  end

  def student_index
    @timesheets = Timesheet.all
  end

  def new
    @pay_period = Date.parse(params[:pay_period])
    @user = User.current
    @time_entries = @user.time_entries
    @timesheet = Timesheet.new
  end

  def create #make a new timesheet from user input
    @timesheet = Timesheet.new(:user_id => params[:user_id], :pay_period => params[:pay_period])

    respond_to do |format|
      if @timesheet.save
        flash[:notice] = 'Timesheet was successfully created.'
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
      end
    end
    
  end

  def show
    @timesheet = Timesheet.find(6)
    
    if @timesheet.paid?
      flash[:notice] = 'Person has been paid'
    else
      flash[:notice] = 'Person has not been paid'
    end
    redirect_to :action =>'index'
  end

  #need to be edited to the actual dates/person
  def print

    @weekof = Date.parse(params[:weekof])   
    name = User.current.firstname
    wage = User.current.wage.amount.to_s
    current = Date.today
    beginning = params[:weekof]
    beginning_date = Date.parse(beginning)

    #TODO change the name of the default scopes on TimeEntry for dates, they need to express that the collection includes the dates indicated.
    usrtiments = TimeEntry.foruser(User.current).after(beginning_date).before(beginning_date + 6.days)

    # @mon = (usrtiments.select {|t| t.spent_on == @weekof}).inject(0) {|sum, x| sum + x.hours}
    # @tue = (usrtiments.select {|t| t.spent_on == (@weekof + 1)}).inject(0) {|sum, x| sum + x.hours} 
    # @wed = (usrtiments.select {|t| t.spent_on == (@weekof + 2)}).inject(0) {|sum, x| sum + x.hours}
    # @thu = (usrtiments.select {|t| t.spent_on == (@weekof + 3)}).inject(0) {|sum, x| sum + x.hours}
    # @fri = (usrtiments.select {|t| t.spent_on == (@weekof + 4)}).inject(0) {|sum, x| sum + x.hours}
    # @sat = (usrtiments.select {|t| t.spent_on == (@weekof + 5)}).inject(0) {|sum, x| sum + x.hours}
    # @sun = (usrtiments.select {|t| t.spent_on == (@weekof + 6)}).inject(0) {|sum, x| sum + x.hours}

    @mon = 1
    @tue = 1
    @wed = 1
    @thu = 1
    @fri = 1
    @sat = 0
    @sun = 0

    hours = @mon + @tue + @wed + @thu + @fri + @sat + @sun
    status =""

    #need to check for valid datetime instead of nil
    if Timesheet.find(6).paid != nil
      status = "Paid"
    elsif Timesheet.find(6).paid == nil && Timesheet.find(6).submitted != nil
      status = "Submitted, but not paid"
    else
      status = "Not submitted and not paid"
    end

    if hours == 0
      flash[:warning] = 'You do not have any hours for the specified week!  Add hours to print a timecard.'
      redirect_to :action => 'index'
    else  #method in timesheethelper
      send_data (generate_timesheet_pdf(name, wage, current, beginning, @mon, @tue, @wed, @thu, @fri, @sat, @sun,status),
        :filename => name + "_timecard_from_" + beginning.to_s + "_to_" + (@weekof + 6.days).to_s + ".pdf",
        :type => "application/pdf")
    end
  end

  def edit
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
    flash[:warning] = "Are you sure you want to delete this timesheet?"
    #@timesheet = Timesheet.all
    @timesheet = Timesheet.all.paginate(:page => params[:timesheet_page], :per_page =>2)
    # @timesheet.destroy
    # redirect_to :action => "index"
  end

  def sort_name   
    @timesheets = Timesheet.all.paginate(:page => params[:timesheet_page], :per_page =>2, :order => 'name')
  end

  private

  
  def sort_wage

  end

  def print_pdf(name, wage, current, beginning, mon, tue, wed, thu, fri, sat, sun)
    beginning = Date.parse(beginning)
    Prawn::Document.new do
    font_size(16)
    text "DMC Student Employee Timesheet", :style => :bold, :align => :center
    font_size(12)
    pad_top(15){ text "Student Name:<b> " + name + "</b>       Student Hourly Wage: $" + wage, :align => :center, :inline_format => true }
    pad_top(10){ text "Pay period for this timesheet:   From -<b> " + beginning.strftime("%D") + "</b>  To -<b> " + (beginning + 6.days).strftime("%D")  + "</b>", :align => :center, :inline_format => true }
    font_size(14)
    pad_top(10){ text "Report of hours worked", :style => :bold}
    font_size(12)
    table([ ["Day", "Date", "# Hours Worked"] ], :column_widths => [108, 216, 216], :cell_style => {:height => 21})
    table([ ["Monday", beginning, mon],
    [" ", "", ""],
    ["Tuesday", beginning + 1.days, tue],
    [" ", "", ""],
    ["Wednesday", beginning + 2.days, wed],
    [" ", "", ""],
    ["Thursday",  beginning + 3.days, thu],
    [" ", "", ""],
    ["Friday",  beginning + 4.days, fri],
    [" ", "", ""],
    ["Saturday", beginning + 5.days, sat],
    [" ",  "", ""],
    ["Sunday",  beginning + 6.days, sun],
    [" ",  "", ""],
    ["", "", "Total Hours: " + (mon + tue + wed + thu + fri + sat + sun).to_s]], :column_widths => [108, 216, 216], :cell_style => {:height => 21})
    pad_top(30) { table([[" "],["*Student's signature                                                      Date"]], :column_widths=> [360]) } 

    pad_top(20) { text "*NOTE: Your signature certifies that this document reflects actual hours worked in accordance with wage and hours laws" }
    pad_top(10) { dash(7, :space => 7, :phase => 0) }
    stroke_horizontal_line 0, 540
    pad_top(10) { text "For Processing Dept Use Only:", :style => :bold }
    pad_top(15) {dash(1, :space => 0, :phase => 0) }
    pad_top(15) { table([[" "],["Processed By                                                                Date"]], :column_widths=> [360]) }
    end.render
  end
  
  def find_first_monday(year)
    t = Date.new(year, 1,1).wday     #checks which day (Mon = 1, Sun = 0) is first day of the year 
    if t == 0
      return Date.new(year, 1,2)
    elsif t == 1
      return Date.new (year, 1,1)
    else
      return Date.new (year, 1,(1+8-t))     #cases designed to return the first Monday of the year's date
    end
  end
end
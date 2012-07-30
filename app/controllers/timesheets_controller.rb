class TimesheetsController < ApplicationController
  unloadable
  before_filter :find_timesheets

  #include SortHelper
  #include TimelogHelper
  #include CustomFieldsHelper

  def index
    @printed = @timesheets.is_printed.is_not_submitted.is_not_paid
    @submitted = @timesheets.is_printed.is_submitted.is_not_paid
    @paid = @timesheets.is_printed.is_submitted.is_paid

  end

  def new

    if params[:date].present?
      @year_selected = params[:date][:year].to_i
    else
       @year_selected = Time.current.year
    end

    if params[:timesheet].present?
      @user = User.find(params[:timesheet][:user_id])
    elsif params[:user].present?
      @user = User.find(params[:user].to_i)
    else
      @user = User.current
    end

    #get the first week of the current year
    yearstart = find_first_monday(@year_selected)

    #get the zero-indexed list of weeks in the current year for select
    @weeks = []
    (0..51).each do |i|
      @weeks << [(yearstart + i.weeks).strftime("Week of %B %d"), (i)]
    end

    if params[:cweek].present?
      @cweek = params[:cweek].to_i + 1  #we add one, because select_tag returns zero-indexed
    else
      @cweek = Date.today.cweek
    end

    @weekof = yearstart + (@cweek - 1).weeks

    @entries = TimeEntry.foruser(@user).on_tweek(@cweek).on_tyear(@year_selected).sort_by_date

    issues = Issue.from_date(@weekof).until_date(@weekof + 6.days)
    @fdshifts = issues.fdshift
    @lcshifts = issues.lcshift
    @goals = Issue.foruser(@user).goals
    @tasks = Issue.foruser(@user).tasks

    #@entries_by_day = []

    # (0..6).each do |i| 
    #   day = (@weekof + i.days)
    #   @entries_by_day << cur_week_entries.select {|t| t.spent_on == day}
    # end
  end

  def create

    yearstart = find_first_monday(Time.current.year)

    if params[:weekof].present?
      weekof = yearstart + (params[:weekof].to_i - 1).weeks
    else
      flash[:notice] = "You must specify a pay period."
      redirect_to :action => 'new'
    end

    if params[:user].present?
      user = User.find(params[:user].to_i)
    else
      user = User.current
    end

    timesheet = Timesheet.new
    timesheet.user = user
    timesheet.weekof = weekof

    if timesheet.save
      flash[:notice] = "Timesheet for #{user.name} for the week starting on #{timesheet.weekof} was successfully created."
      redirect_to :action => 'index'
    else                                            
      flash[:warning] = timesheet.errors.full_messages #'Invalid Options... Try again!'
      redirect_to :action => 'new'
    end
  end

  def edit
  end

  def update
  end

  private

  def find_timesheets
    if User.current.is_stustaff?
      @timesheets = Timesheet.weekof_from(DateTime.now - 1.year).for_user(User.current)
      @drafts = @timesheets.is_not_printed.is_not_submitted.is_not_paid
    elsif User.current.is_admstaff?
      @timesheets = Timesheet.weekof_from(DateTime.now - 1.year)
    else
      render_403
      return false
    end
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
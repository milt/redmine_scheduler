class TimesheetsController < ApplicationController
  unloadable
  before_filter :find_timesheets

  include SortHelper
  include TimelogHelper
  include CustomFieldsHelper

  def index
    @printed = @timesheets.is_printed.is_not_submitted.is_not_paid
    @submitted = @timesheets.is_printed.is_submitted.is_not_paid
    @paid = @timesheets.is_printed.is_submitted.is_paid

  end

  def new
    sort_init 'spent_on', 'desc'
    sort_update 'spent_on' => 'spent_on',
                'user' => 'user_id',
                'activity' => 'activity_id',
                'project' => "#{Project.table_name}.name",
                'issue' => 'issue_id',
                'hours' => 'hours'

    if params[:date].present?
      @year_selected = params[:date][:year].to_i
    else
       @year_selected = Time.current.year
    end


    #get the first week of the current year
    yearstart = find_first_monday(@year_selected)

    #get the zero-indexed list of weeks in the current year for select
    @weeks = []
    (0..51).each do |i|
      @weeks << [(yearstart + i.weeks).strftime("Week of %B %d"), (i)]
    end

    #flash[:notice] = "all weeks? #{@weeks.inspect}"
    if params[:cweek].present?
      @cweek = params[:cweek].to_i + 1  #we add one, because select_tag returns zero-indexed
    else
      @cweek = Date.today.cweek
    end

    #flash[:notice] = "cweek is #{@cweek.inspect}"
    @weekof = yearstart + (@cweek - 1).weeks

    @entries = TimeEntry.foruser(User.current).on_tweek(@cweek).on_tyear(@year_selected)

    #@entries_by_day = []

    # (0..6).each do |i| 
    #   day = (@weekof + i.days)
    #   @entries_by_day << cur_week_entries.select {|t| t.spent_on == day}
    # end
  end

  def create
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
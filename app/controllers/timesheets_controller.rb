class TimesheetsController < ApplicationController
  unloadable
  before_filter :find_timesheets, :only => :index
  before_filter :find_timesheet, :only => [:print, :show, :edit, :update, :submit, :approve, :delete, :reject]
  before_filter :require_admstaff, :only => [:approve,:reject]
  before_filter :wage_check, :except => [:approve,:delete,:reject]
  include TimesheetHelper
  include TimesheetsHelper
  require "prawn"   #needed for pdf generation

  def index
    @submitted = @timesheets.is_submitted.is_not_approved
    @approved = @timesheets.is_submitted.is_approved
  end

  def new
    @edit = true
    @past_weeks = dates(Date.today.beginning_of_week, (Date.today-365.day).beginning_of_week) #get list of valid weeks to make timesheets for
    find_user #find the user to make the sheet for
    find_selection_week_year #process the result of the week selection, creates @cweek and @year_selected
    yearstart = find_first_monday(@year_selected) #no longer used?
    @weekof = Date.commercial(@year_selected,@cweek,1)
    validate_existence(@user,@weekof) #see if there is an existing timesheet
    find_entries_by_day(@weekof) # pull entries for viewing/editing
    find_shifts_by_day(@weekof) # pull shifts for adding time entries
    get_goals(@user)
    get_tasks(@user)
  end

  def create
    find_selection_week
    find_user
    timesheet = Timesheet.new
    timesheet.user = @user
    timesheet.weekof = @weekof

    if timesheet.save
      if params[:creatensubmit] == 'yes'
        @timesheet = timesheet
        submit  
      else
        redirect_to :action => 'index'
      end
    else                                            
      flash[:warning] = timesheet.errors.full_messages #'Invalid Options... Try again!'
      redirect_to :action => 'new'
    end
  end

  def print
    weekof = @timesheet.weekof.to_date
    name = @timesheet.user.name

    if @timesheet.print_now && @timesheet.save
      send_data (generate_timesheet_pdf(@timesheet),
        :filename => name + "_timecard_from_" + weekof.to_s + "_to_" + (weekof + 6.days).to_s + ".pdf",
        :type => "application/pdf") and return
    else
      flash[:warning] = 'Could not print timesheet. I need some better error handling'
      redirect_to :action => 'index'
    end
  end

  def show
    @show = true
    @year_selected = @timesheet.weekof.year
    @cweek = @timesheet.weekof.to_date.cweek
    find_entries_by_day(@weekof)
    if @timesheet.approved.present?
      @wage = @timesheet.approve_time_wage.to_s
    else
      @wage = @timesheet.user.wage.amount.to_s
    end
  end

  def edit
    @edit = true
    @weekof = @timesheet.weekof.to_date
    @year_selected = @timesheet.weekof.year
    @cweek = @timesheet.weekof.to_date.cweek
    find_entries_by_day(@weekof)
    find_shifts_by_day(@weekof)
  end

  def update
  end

  def submit
    if @timesheet.submit_now && @timesheet.save
      flash[:notice] = "Timesheet for #{@timesheet.user.name} for the week starting on #{@timesheet.weekof} was successfully submitted."
      redirect_to :action => 'index'
    else
      flash[:warning] = @timesheet.errors.full_messages
      redirect_to :action => 'index'
    end
  end

  def approve
    if @timesheet.approve_now && @timesheet.save
      flash[:notice] = "Timesheet for #{@timesheet.user.name} for the week starting on #{@timesheet.weekof} was successfully approved."
      redirect_to :action => 'index'
    else
      flash[:warning] = @timesheet.errors.full_messages
      redirect_to :action => 'index'
    end
  end

  def delete
    if @timesheet.status != :draft
      require_admstaff
    end

    if @timesheet.delete_now && @timesheet.save
      flash[:notice] = "Timesheet has been successfully deleted!"
      redirect_to :action => 'index'
    else
      flash[:warning] = "An error occurred when deleting the timesheet.."
      redirect_to :action => 'index'
    end
  end

  def reject
    if @timesheet.reject_now && @timesheet.save
      flash[:notice] = "Timesheet successfully rejected"
      redirect_to :action => 'index'
    else
      flash[:notice] = "An error occurred when rejecting timesheet"
      redirect_to :action => 'index'
    end
  end

  private

  def require_admstaff
    return unless require_login
    if !User.current.is_admstaff?
      render_403
      return false
    end
    true
  end

  def wage_check
    unless User.current.is_admstaff?
      session[:return_to] = request.referer
      if User.current.wage.nil?
        flash[:warning] = "You don't seem to be assigned a wage. Please speak to your manager."
        redirect_to session[:return_to]
        #redirect_to :action => 'index'  #works well with all actions except when triggered going into timesheet index
      end
    end
  end

  def find_user
    if params[:timesheet].present?
      @user = User.find(params[:timesheet][:user_id])
    elsif params[:user].present?
      @user = User.find(params[:user].to_i)
    else
      @user = User.current
    end
  end

  def find_timesheet
    if params[:id].present?
      @timesheet = Timesheet.find(params[:id])
    end
    if User.current.is_admstaff?
      unless @timesheet.actions[:admin].map {|a| a[1]}.include?(action_name.to_sym)
        flash[:warning] = "Invalid action for this timesheet!"
        redirect_to :action => 'index'
      end
    elsif User.current.is_stustaff?
      unless @timesheet.actions[:staff].map {|a| a[1]}.include?(action_name.to_sym)
        flash[:warning] = "Invalid action for this timesheet, or you do not have permission!"
        redirect_to :action => 'index'
      end
    else
      render_403
      return false
    end
  end

  def find_timesheets
    if User.current.is_stustaff?
      @timesheets = Timesheet.weekof_from(DateTime.now - 3.years).for_user(User.current)
      @drafts = @timesheets.is_not_submitted.is_not_approved
      if !@drafts.empty?
        flash[:warning] = "This is a reminder that you have an unsubmitted timesheet"
      end
    elsif User.current.is_admstaff?
      @timesheets = Timesheet.weekof_from(DateTime.now - 3.years)
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

  def validate_existence(user,weekof)
    existing = Timesheet.for_user(user).weekof_on(weekof)
    if !existing.empty?
      flash.now[:warning] = "There is already a timesheet for the selected week. Please select another."
    end
  end

  def find_entries_by_day(weekof)
    if !@timesheet.nil?
      @entries_by_day = @timesheet.entries_for_week.group_by(&:spent_on)
    else
      @entries = TimeEntry.foruser(@user).from_date(weekof).until_date(weekof + 1.week).sort_by_date
      @entries_by_day = @entries.group_by(&:spent_on)  
    end
  end

  def dates(to,from)
    dates = []
    date = to
    while date >= from do
      dates << [date.strftime("Week of %B %d, Year %Y"), date.to_s]
      date -= 7.day
    end
    return dates
  end

  #retrieving information from selection
  def find_selection_week_year
    if params[:week_sel].present?
      w = Date.parse(params[:week_sel])
      @cweek = w.cweek
      @year_selected = w.year
    else
      @cweek = Date.today.cweek
      @year_selected = Date.today.year
    end
  end

  #I know this is more or less redundant from method above
  def find_selection_week
    if params[:weekof].present?
      @weekof = Date.parse(params[:weekof])
    else
      flash[:notice] = "You must specify a pay period."
      redirect_to :action => 'new'
    end
  end

  def find_shifts_by_day(weekof)
    issues = Issue.from_date(weekof).until_date(weekof + 1.week)
    fdshifts = issues.fdshift
    lcshifts = issues.lcshift
    
    @shifts_by_day = (fdshifts+lcshifts).group_by(&:start_date)
  end

  def get_goals(user)
    @goals = Issue.foruser(user).goals
  end

  def get_tasks(user)
    @tasks = Issue.foruser(user).tasks
  end
end

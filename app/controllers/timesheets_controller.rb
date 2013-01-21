class TimesheetsController < ApplicationController
  unloadable
  before_filter :find_timesheets, :only => :index
  before_filter :find_timesheet, :only => [:print, :show, :edit, :update, :submit, :approve, :delete, :reject]
  before_filter :require_admstaff, :only => [:approve,:reject]
  before_filter :wage_check, :except => [:approve,:delete,:reject]
  include TimesheetHelper
  include TimesheetsHelper  #I know this must be the strangest thing, its like seeing doubles
  require "prawn"   #needed for pdf generation

  def index
    @submitted = @timesheets.is_submitted.is_not_approved
    @approved = @timesheets.is_submitted.is_approved
  end

  def new
    
    @past_weeks = dates(Date.today.beginning_of_week, (Date.today-365.day).beginning_of_week)

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
    @existing = Timesheet.for_user(User.current).weekof_on(@weekof)

    if !@existing.empty?
      flash.now[:warning] = "There is already a timesheet for the selected week. Please select another."
    end

    @entries = TimeEntry.foruser(@user).on_tweek(@cweek).on_tyear(@year_selected).sort_by_date
    #@entries_days_of_week = @entries.map(&:spent_on).uniq.sort   #uniq.sort doesn't seem to be needed, converts array of timeentries to array of dates
    @entries_by_day = @entries.group_by(&:spent_on)  

    issues = Issue.from_date(@weekof).until_date(@weekof + 6.days)
    @fdshifts = issues.fdshift
    @lcshifts = issues.lcshift
    
    @shifts_by_day = (@fdshifts+@lcshifts).group_by(&:start_date)   #concatenating the arrays of lc and fd shifts should solve bug 1240

    @goals = Issue.foruser(@user).goals
    @tasks = Issue.foruser(@user).tasks

    @edit = false
    @show = false

  end

  def create
    #session[:return_to] = request.referer
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


    #need to check whether the timesheet has already been submitted..
    #need to check whether there is hour to the timesheet before saving, else cannot submit
    #might not be the best way to code, the block should be replaced a call to submit method
    
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
    #session[:return_to] = request.referer
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
    #session[:return_to] = request.referer
    @edit = false
    @show = true

    issues = Issue.from_date(@timesheet.weekof).until_date(@timesheet.weekof + 6.days)

    @shifts_by_day = issues.group_by(&:start_date)

  end

  def edit
    #session[:return_to] = request.referer
    @edit = true
    @show = false

    issues = Issue.from_date(@timesheet.weekof).until_date(@timesheet.weekof + 6.days)

    @shifts_by_day = issues.group_by(&:start_date)

  end

  def update
  end

  def submit
    #session[:return_to] = request.referer
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

end

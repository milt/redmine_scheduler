class TimesheetsController < ApplicationController
  unloadable
  load_and_authorize_resource

  before_filter :wage_check, :except => [:approve,:delete,:reject]

  def index
    if params[:user]
      @user = User.find(params[:user])
      @timesheets = @timesheets.for_user(@user)
    end

    @submitted = @timesheets.is_submitted.is_not_approved.page(params[:submitted_page])
    @approved = @timesheets.is_submitted.is_approved.page(params[:approved_page])
    @rejected = @timesheets.rejected.page(params[:rejected_page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @timesheet = Timesheet.new

    if params[:user]
      @user = User.find(params[:user])
    else
      if User.current.is_admstaff?
        @user = Group.stustaff.first.users.first
      else
        @user = User.current
      end
    end

    params[:weekof] ? @weekof = Date.parse(params[:weekof]) : @weekof = Date.today.beginning_of_week


    @time_entries = @user.time_entries.on_week(@weekof).not_on_timesheet
    @previous_sheets = @user.timesheets.weekof_on(@weekof)

    @shifts = Issue.shifts.from_date(@weekof).until_date(@weekof + 6.days)
    @fd_shifts = @shifts.fdshift
    @lc_shifts = @shifts.lcshift.foruser(@user)

    respond_to do |format|
      if rejected_check && User.current.is_stustaff?
        format.html do
          flash[:notice] =  'There is already a rejected timesheet for this user. Please edit and resubmit or delete it.'
          redirect_to edit_timesheet_path(@prev_rejected_sheets.first)
        end
      else
        format.html
        format.js
      end
    end
  end

  def create
    @timesheet = Timesheet.new(params[:timesheet])
    @timesheet.user = User.find(params[:user])
    @timesheet.weekof = Date.parse(params[:weekof])
    @timesheet.commit_time_entries

    if @timesheet.save
      flash[:notice] = 'Timesheet submitted. Please print it out and submit it to the manager.'
      redirect_to @timesheet
    else
      flash[:warning] = "Timesheet could not be saved: #{@timesheet.errors.full_messages}"
      redirect_to action: 'new', user: @user, weekof: @timesheet.weekof
    end
  end

  def show

    if @timesheet.time_entries.empty?
      @time_entries = @timesheet.user.time_entries.on_week(@timesheet.weekof)
    else
      @time_entries = @timesheet.time_entries
    end

    @weekof = @timesheet.weekof

    respond_to do |format|
      format.html
      format.pdf { render :layout => false }
    end
  end

  def print
    if @timesheet.print_now && @timesheet.save
      redirect_to action: :show, format: :pdf, id: @timesheet
    else
      flash[:warning] = 'Could not print timesheet. I need some better error handling'
      redirect_to :action => 'index'
    end
  end

  def edit
    @user = @timesheet.user

    @weekof = @timesheet.weekof

    @time_entries = @user.time_entries.on_week(@weekof).not_on_timesheet

    @previous_sheets = []

    @shifts = Issue.shifts.from_date(@weekof).until_date(@weekof + 6.days)
    @fd_shifts = @shifts.fdshift
    @lc_shifts = @shifts.lcshift.foruser(@user)

    respond_to do |format|
      format.html
      #format.js
    end
  end

  def update
    @timesheet.commit_time_entries
    @timesheet.submit_now

    if @timesheet.update_attributes(params[:timesheet])
      flash[:notice] = "Timesheet for #{@timesheet.user.name} for the week starting on #{@timesheet.weekof} was successfully resubmitted."
      redirect_to @timesheet
    else
      flash[:warning] = "Could not save. Errors: " + timesheet.errors.full_messages.join(", ")
      redirect_to edit_timesheet_path(@timesheet)
    end
  end

  def submit
    if @timesheet.submit_now && @timesheet.save
      flash[:notice] = "Timesheet for #{@timesheet.user.name} for the week starting on #{@timesheet.weekof} was successfully submitted."
      redirect_to :action => 'index'
    else
      flash[:warning] = "Could not save. Errors: " + timesheet.errors.full_messages.join(", ")
      redirect_to :action => 'index'
    end
  end

  def approve
    @timesheet.approve_now

    if @timesheet.save
      flash[:notice] = "Timesheet for #{@timesheet.user.name} for the week starting on #{@timesheet.weekof} was successfully approved."
      redirect_to :action => 'index'
    else
      flash[:warning] = "Could not save. Errors: " + timesheet.errors.full_messages.join(", ")
      redirect_to :action => 'index'
    end
  end

  def delete
    @timesheet.destroy

    if @timesheet.save
      flash[:notice] = "Timesheet has been successfully deleted!"
      redirect_to :action => 'index'
    else
      flash[:warning] = "An error occurred when deleting the timesheet.."
      redirect_to :action => 'index'
    end
  end

  def reject
    @timesheet.reject_now

    if @timesheet.save
      flash[:notice] = "Timesheet successfully rejected"
      redirect_to :action => 'index'
    else
      flash[:notice] = "An error occurred when rejecting timesheet"
      redirect_to :action => 'index'
    end
  end

  private

  def wage_check
    unless User.current.is_admstaff?
      session[:return_to] = request.referer
      if User.current.wage.nil?
        flash[:warning] = "You don't seem to be assigned a wage. Please speak to your manager."
        redirect_to session[:return_to]
      end
    end
  end

  def rejected_check
    @prev_rejected_sheets = @user.timesheets.rejected
    if @prev_rejected_sheets.empty?
      return false
    else
      return true
    end
  end

  def get_goals(user)
    @goals = Issue.foruser(user).goals
  end

  def get_tasks(user)
    @tasks = Issue.foruser(user).tasks
  end
end

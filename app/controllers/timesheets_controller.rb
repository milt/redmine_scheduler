class TimesheetsController < ApplicationController
  unloadable

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
    @timesheet = Timesheet.find (params[:id])
  end

  def update
    @timesheet = Timesheet.find (params[:id])
    @timesheet.update_attributes (params[:timesheet])
    flash[:notice] = "Timesheet has been updated"
    redirect_to @timesheet
  end

  def delete
  end
end

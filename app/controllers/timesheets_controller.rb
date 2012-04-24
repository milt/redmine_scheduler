class TimesheetsController < ApplicationController
  unloadable


  def index
    @timesheets = Timesheet.all
  end

  def new
    @timesheet = Timesheet.new
  end

  def create #make a new timesheet from user input
    @timesheet = Timesheet.new(params[:timesheet])

    respond_to do |format|
      if @timesheet.save
        flash[:notice] = 'Skill was successfully created.'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @timesheet, :status => :created,
                    :location => @timesheet }
      else                                               
        flash[:warning] = 'Invalid Options... Try again!'
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @timesheet.errors,
                    :status => :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end
end

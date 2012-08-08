class TimeslotsController < ApplicationController
  unloadable

  def index
    @timeslots = Timeslot.after_now
  end

  def book
  end

  def find
    #make a find for all labcoach shifts
    @shifts = Issue.lcshift
    @coaches = Group.stustaff.first.users #find student staff (lab coaches)

    #apply filtering to shifts. each one of these methods modifys @shifts
    filter_dates(@shifts)
    filter_coaches(@shifts)

    @dates = @shifts.map {|s| s.start_date }

  end

  private #lot of crazy in here.

  def filter_dates(shifts)
    #handle date params
    if params[:from].present?
      @from = Date.new(params[:from][:year].to_i,params[:from][:month].to_i,params[:from][:day].to_i)
    else
      @from = Date.today
    end

    if params[:to].present?
      @to = Date.new(params[:to][:year].to_i,params[:to][:month].to_i,params[:to][:day].to_i)
    else
      @to = Date.today + 4.weeks
    end
    #modify find
    @shifts = shifts.from_date(@from).until_date(@to)
  end

  def filter_coaches(shifts)
    #handle coach params
    if params[:coach_ids].present?
      @coaches_selected = params[:coach_ids].map {|id| User.find(id.to_s)}
    elsif !params[:coach_ids].present? && params[:commit].present?
      flash[:warning] = "You have not selected any coaches!"
      @coaches_selected = []
    else
      @coaches_selected = @coaches
    end
    
    unless @coaches_selected == @coaches
      coaches_deselected = @coaches.map(&:id) - @coaches_selected.map(&:id)
      @shifts = shifts.omit_user_ids(coaches_deselected)
    end
  end
end

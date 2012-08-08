class TimeslotsController < ApplicationController
  unloadable

  def index
    @timeslots = Timeslot.after_now
  end

  def book
  end

  def find
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

    @coaches = Group.stustaff.first.users
    if params[:coach_ids].present?
      @coaches_selected = params[:coach_ids].map {|id| User.find(id.to_s)}
    else
      @coaches_selected = @coaches
    end

    @shifts = Issue.lcshift.from_date(@from).until_date(@to)
    @dates = @shifts.map {|s| s.start_date }

  end
end

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

    @shifts = Issue.lcshift.from_date(@from).until_date(@to)
  end
end

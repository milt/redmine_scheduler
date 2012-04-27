class CommandController < ApplicationController
  unloadable

  def index
    
    if params[:hours].present?
      @hours = params[:hours].to_f
    else
      @hours = 20
    end
    
    if params[:weeks].present?
      @weeks = params[:weeks].to_i
    else
      @weeks = 2
    end
    
    @workgroups = User.current.workgroups
  end
  
  def grab
    if params[:coach_id].present?
      @coach = User.find(params[:coach_id])
    end
    
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id]) unless Issue.find(params[:issue_id]).is_shift?
    end
    
    if params[:from].present? #&& (Date.parse(params[:from]) >= Date.today)
      #@from = Date.parse(params[:from])
      @from = Date.civil(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
    else
      @from = Date.today
    end
    
    if params[:to].present? #&& (Date.parse(params[:to]) >= @from)
      @to = Date.civil(params[:to][:year].to_i, params[:to][:month].to_i, params[:to][:day].to_i)
    else
      @to = Date.today + 2.weeks
    end
    
    if @coach.get_open_slots_by_date_range(@from, @to).nil?
      @slothash = {"No Shifts"=>nil}
    else
      @slothash = @coach.get_open_slots_by_date_range(@from, @to).group_by {|t| t.issue.start_date}
      @dates = @slothash.keys.sort
    end
  end
end

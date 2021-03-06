class TimeslotsController < ApplicationController
  unloadable
  authorize_resource

  def index
    @timeslots = Timeslot.after_now
  end

  def book
  end

  def show
    @timeslot = Timeslot.find(params[:id])

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml { render :xml => @timeslot }
    end
  end

  def find
    #make a find for all labcoach shifts
    @shifts = Issue.lcshift
    @coaches = Group.stustaff.first.users.active #find student staff (lab coaches)
    @skillcats = Skillcat.all.sort_by(&:name)

    @skills_list = []

    @skills_list = skill_arr_create
    
    find_params

    #apply filtering to shifts. each one of these methods modifies @shifts
    filter_dates(@shifts)
    filter_coaches(@shifts)
    filter_skills(@shifts) unless @skill_selected.nil?   #this might be where error occurred

    @dates = @shifts.map(&:start_date).uniq.sort

    @shifts_by_date = @shifts.group_by(&:start_date)
    @slots_by_shift = @shifts.map {|s| s.timeslots}.flatten.group_by(&:issue)

  end

  private #lot of crazy in here.

  def skill_arr_create
    skill_arr = []


    @skillcats.each do |cat|
      skill_arr << ["", nil]
      skill_arr << ["-------" + cat.name + "-------", nil]
      skills_sorted = cat.skills.sort_by(&:name)

      skills_sorted.each do |skill|
        skill_arr << [skill.name, skill.id] 
      end
    end

    skill_arr   #returns with sorted skills array
  end

  def find_params
    if params[:from].present?
      @from = Date.new(params[:from][:year].to_i,params[:from][:month].to_i,params[:from][:day].to_i)
    else
      @from = Date.today
    end

    if params[:to].present?
      @to = Date.new(params[:to][:year].to_i,params[:to][:month].to_i,params[:to][:day].to_i)
    else
      @to = Date.today + 2.weeks
    end

    if params[:coach_ids].present?
      @coaches_selected = params[:coach_ids].map {|id| User.find(id.to_s)}
    elsif !params[:coach_ids].present? && params[:commit].present?
      flash[:warning] = "You have not selected any coaches!"
      @coaches_selected = []
    else
      @coaches_selected = []   #this clears the checkboxes when first going into timeslot/find view.
    end

    if params[:sel_skill].present?
      @skill_selected = Skill.find(params[:sel_skill])
      @skill_choice = @skill_selected.id
    else
      @skill_choice = 0
    end
    
    if params[:extant_booking_id].present?
      @extant_booking = Booking.find(params[:extant_booking_id])
    end

  end

  def filter_dates(shifts)
    #modify find
    @shifts = shifts.from_date(@from).until_date(@to)
  end

  def filter_coaches(shifts)
    unless @coaches_selected == @coaches
      coaches_deselected = @coaches.map(&:id) - @coaches_selected.map(&:id)
      @shifts = shifts.omit_user_ids(coaches_deselected)
    end
  end

  def filter_skills(shifts)
    #if !@skill_selected.nil?
      @shifts = shifts.select {|s| s.skills.map(&:id).include?(@skill_selected.id)}
    #end
  end
end

class BookingController < ApplicationController
  unloadable


  def index
    unless session[:selected].nil?
      @selected = session[:selected]
      @skills = Skill.find_each(@selected)
    end
    @timeslots = Timeslot.all
    @unbooked = @timeslots.select {|t| t.booking.nil? && (t.slot_date > Date.today)}
    @allskills = Skill.all
  end

  def checkskill
    @skill = Skill.find(params[:skill_id])
    session[:selected] << @skill[:id]
    redirect_to :action => 'index'
  end
  
  def uncheckskill
    @skill = Skill.find(params[:skill_id])
    session[:selected].delete(@skill[:id])
    redirect_to :action => 'index'
  end
  
  def book
  end
end

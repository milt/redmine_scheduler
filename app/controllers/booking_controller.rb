class BookingController < ApplicationController
  unloadable


  def index
    #check for incoming search parameters, and instantiate an empty array if there are none.
    if params[:skill_ids].nil?
      @filter = []
    else
      @filter = params[:skill_ids]
    end
    
    @timeslots = Timeslot.all
    @skills = Skill.all
    @selskills= @skills.select {|s| @filter.include?(s.id.to_s)}
    @unbooked = @timeslots.select {|t| t.booking.nil? && (t.slot_date > Date.today)}
    @selslots = []
    
    
    @selskills.each do |skill|
      skill.timeslots.each do |slot|
        unless @selslots.include?(slot)
          @selslots << slot
        end
      end
    end
      
  end
  
  def book
  end
end
